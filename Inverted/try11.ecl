//EXPORT try9 := 'todo';


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

 
//expr2:='[a-zA-Z][.][a-zA-Z][.]*[a-zA-Z]*[.]*[a-zA-Z]*';




 
enumDocs    := Inverted.EnumeratedDocs(info,  inDocs);
p1 := Inverted.ParsedText(enumDocs);
rawPostings := Inverted.RawPostings(enumDocs);

OUTPUT(rawPostings,,'~ONLINE::Farah::OUT::Solution1',OVERWRITE);


/*
res:=NORMALIZE(NestedDS,COUNT(LEFT.Values),
          TRANSFORM(OutRec,
                    SELF.val := LEFT.Values[COUNTER].val,Self.term:=LEFT.Values[COUNTER].val,SELF.len:=length(LEFT.Values[COUNTER].val),SELF.kwp:=LEFT.kwp+COUNTER,SELF.keywords:=if(length(LEFT.Values[COUNTER].val)=1,1,LEFT.keywords)
										,SELF.lentext:=length(LEFT.Values[COUNTER].val),SELF.typterm:=if(length(LEFT.Values[COUNTER].val)=1,1,LEFT.typterm);
                    SELF := LEFT,
										 ));
										
output(res);
*/

//ds := DATASET([{'thee is anew A.B.C and V.R'}], {STRING100 line}); 
//PATTERN expr :=PATTERN(U'[a-zA-Z][.][a-zA-Z]*[.][a-zA-Z]*[.]*[a-zA-Z]*');
//PATTERN expr3 :=PATTERN('[a-zA-Z][.][a-zA-Z]*[.][a-zA-Z]*[.]*[a-zA-Z]*');
//PATTERN expr4 :=PATTERN('[a-zA-Z][.][a-zA-Z]*');
//PATTERN expr5 :=PATTERN('[a-zA-Z]+');













FlatRec := RECORD
	//STRING Value1;
		//STRING Value2;
	RawPostings
END;

//FlatFile := DATASET([{'C.A.B'},
	//				 {'V.R'},
		//			 {'D.S.Y'}],FlatRec);

OutRec := RECORD
	rawPostings;
	//string val:='';
	
END;
P_Recs := TABLE(rawPostings, OutRec);

OUTPUT(P_Recs,NAMED('ParentData'));

expr2:='[a-zA-Z][.][a-zA-Z][.]*[a-zA-Z]*[.]*[a-zA-Z]*';

OutRec NormThem(FlatRec L, INTEGER C) := TRANSFORM
	//SELF.term := REGEXFINDSET(expr2,(STRING)L.term)[C]+'  '+Std.Str.SplitWords((string)L.term,'.')[C];
	SELF.term := REGEXFINDSET(expr2,(STRING)L.term)[C]+'  '+Std.Str.SplitWords((string)L.term,'.')[C];
	
	SELF := L;
 
	
END;
ChildRecs := NORMALIZE(rawPostings,LEFT.keywords,NormThem(LEFT,COUNTER));//#of keywords  rawPostings.keywords

OUTPUT(ChildRecs,NAMED('ChildData'));
  
	

PATTERN expr3 :=PATTERN('[a-zA-Z][.][a-zA-Z]*[.][a-zA-Z]*[.]*[a-zA-Z]*');
//PATTERN expr4 :=PATTERN('[' ']');
PATTERN expr5 :=PATTERN('[\' \'] [a-zA-Z]');
TOKEN JustAWord := expr3  or expr5;
RULE r   := JustAWord ;	
ps1 := { 
 


	out1 := MATCHTEXT(r) }; 
	//p14 := PARSE(ChildRecs, val, r, ps1,Best,MANY, NOT MATCHED);
	//output(p14);
//p1 := PARSE(ds, line, NounPhraseComp1, ps1, BEST,MANY,NOCASE); 