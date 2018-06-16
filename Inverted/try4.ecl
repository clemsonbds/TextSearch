//EXPORT try2 := 'todo';

//EXPORT solution := 'todo';

//EXPORT check := 'todo';
IMPORT TextSearch2.Inverted;
IMPORT TextSearch2.Common;
IMPORT STD;
IMPORT TextSearch2.Inverted.Layouts;




prefix := '~thor::jdh::';
inputName := prefix + 'corrected_lda_ap_txtt_xml';

Work1 := RECORD
  UNICODE doc_number{XPATH('/DOC/DOCNO')};
  UNICODE content{MAXLENGTH(32000000),XPATH('<>')};
  UNICODE text{MAXLENGTH(32000000),XPATH('/DOC/TEXT')};
  UNSIGNED8 file_pos{VIRTUAL(fileposition)};
	UNICODE init;
	
END;


Inverted.Layouts.DocumentIngest cvt(Work1 lr) := TRANSFORM
  SELF.identifier := TRIM(lr.doc_number, LEFT,RIGHT);
  SELF.seqKey := inputName + '-' + INTFORMAT(lr.file_pos,12,1);
  SELF.slugLine := lr.text[1..STD.Uni.Find(lr.text,'.',1)+1];
  SELF.content := lr.content;
	SELF.init:=lr.content;

END;


stem := prefix + 'corrected_lda_ap_txtt_xml';
instance := 'initial2';

ds0 := DATASET(inputName, Work1, XML('/DOC', NOROOT));
inDocs := PROJECT(ds0, cvt(LEFT));
 
info := Common.FileName_Info_Instance(stem, instance);

 
expr:=U'[a-zA-Z][.][a-zA-Z][.]*[a-zA-Z]*[.]*[a-zA-Z]*';



Inverted.Layouts.RawPosting filter(Inverted.Layouts.RawPosting doc) := TRANSFORM
 
 

SELF.term:=REGEXREPLACE( expr,doc.term,STD.Uni.FilterOut(doc.term, '.'));
 SELF := doc;
END;

 

Inverted.Layouts.RawPosting filter2(Inverted.Layouts.RawPosting doc) := TRANSFORM
 
 

SELF.term:=STD.Uni.FindReplace(doc.term,'.','\n');
 


SELF := doc;
END;
 
 

Inverted.Layouts.DocumentIngest filter3(Inverted.Layouts.DocumentIngest doc) := TRANSFORM
 
 
SELF.content:=STD.Uni.FindReplace(doc.content,'.','')+STD.Uni.FindReplace(doc.init,'.','\n');


SELF := doc;
END;



enumDocs    := Inverted.EnumeratedDocs(info,  inDocs);
eee:=STD.Uni.FindReplace(inDocs[1].content,'.','')+STD.Uni.Filter(inDocs[1].init,'.');
output(eee);

p1 := Inverted.ParsedText(enumDocs);
rawPostings := Inverted.RawPostings(enumDocs);

//s:= PROJECT(rawPostings, filter(LEFT));
//s2:=PROJECT(rawPostings, filter2(LEFT));



 
OUTPUT(rawPostings,,'~ONLINE::Farah::OUT::Solution3',OVERWRITE);
//OUTPUT(s,,'~ONLINE::Farah::OUT::Solution2',OVERWRITE);
//OUTPUT(s2,,'~ONLINE::Farah::OUT::Solution4',OVERWRITE);


//enum2:=PROJECT(inDocs, filter3(LEFT));
//OUTPUT(enum2[1].content,named('farah'));

//enumDocs2    := Inverted.EnumeratedDocs(info,  enum2);
//rawPostings2 := Inverted.RawPostings(enumDocs2);




 
