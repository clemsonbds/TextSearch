//EXPORT solution := 'todo';

//EXPORT check := 'todo';
IMPORT TextSearch.Inverted;
IMPORT TextSearch.Common;
IMPORT STD;
IMPORT TextSearch.Inverted.Layouts;



prefix := '~thor::jdh::';
inputName := prefix + 'corrected_lda_ap_txtt_xml';

Work1 := RECORD
  UNICODE doc_number{XPATH('/DOC/DOCNO')};
  UNICODE content{MAXLENGTH(32000000),XPATH('<>')};
  UNICODE text{MAXLENGTH(32000000),XPATH('/DOC/TEXT')};
  UNSIGNED8 file_pos{VIRTUAL(fileposition)};
	set of String init;
	// string init_w_pun;
END;


Inverted.Layouts.DocumentIngest cvt(Work1 lr) := TRANSFORM
  SELF.identifier := TRIM(lr.doc_number, LEFT,RIGHT);
  SELF.seqKey := inputName + '-' + INTFORMAT(lr.file_pos,12,1);
  SELF.slugLine := lr.text[1..STD.Uni.Find(lr.text,'.',1)+1];
  SELF.content := lr.content;
	SELF.init:=[];
//	SELF.init_w_pun:=[];
END;


stem := prefix + 'corrected_lda_ap_txtt_xml';
instance := 'initial2';

ds0 := DATASET(inputName, Work1, XML('/DOC', NOROOT));
inDocs := PROJECT(ds0, cvt(LEFT));
OUTPUT(ENTH(inDocs, 20), NAMED('Sample_20'));//will print only 20 records 

info := Common.FileName_Info_Instance(stem, instance);


enumDocs    := Inverted.EnumeratedDocs(info, inDocs);
p1 := Inverted.ParsedText(enumDocs);
rawPostings := Inverted.RawPostings(enumDocs);

OUTPUT(inDocs,,'~ONLINE::Farah::OUT::Solution',OVERWRITE);
OUTPUT(p1,,'~ONLINE::Farah::OUT::Solution2',OVERWRITE);
OUTPUT(rawPostings,,'~ONLINE::Farah::OUT::Solution3',OVERWRITE);


expr:='[a-zA-Z][.][a-zA-Z]*[.][a-zA-Z]*[.]*[a-zA-Z]*';

initialism:=REGEXFINDSET(expr,(string)inDocs[1].content);
output(initialism);
A :=STD.Str.FilterOut(initialism[1], '.');
output(A);


cont:= RECORD
 inDocs.content;
 inDocs.init;
 //inDocs.init_w_pun;
//set of  string x;
END;;
cont filter(Inverted.Layouts.DocumentIngest doc) := TRANSFORM
//init:=REGEXFINDSET( expr,(string)doc.content);
//SELF.content:=doc.content;
SELF.init:=REGEXFINDSET( expr,(string)doc.content);
//SELF.init_w_pun:=STD.Str.FilterOut((string)SELF.init, '.');
//self.init:=STD.Str.FilterOut(REGEXFINDSET( expr,(string)doc.content), '.');
//to change the field must use self.field
//add new column in data set and search in both 
//output(init);
SELF := doc;
END;
s:= PROJECT(inDocs, filter(LEFT));
output(s);

/*
import python;
string splitwords( set of string w) := embed(Python)
	for i in range (0,2):
		words = w[i].replace('.','')
		
	return words
endembed;
 
//splitwords((set of string)s[1].init);
//set of string B:=['a.n','c.r']; 

 
//output((set of string)s[1].init);
  /*
#A=sr.replace(sr[1],'')
	#return A
	#words = [string w.replace('.', '') for word in w]
 
 splitwords(s[1].init);
 output(s);
 */