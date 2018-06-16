//EXPORT try7 := 'todo';
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
expr2:='[a-zA-Z][.][a-zA-Z][.]*[a-zA-Z]*[.]*[a-zA-Z]*';



Inverted.Layouts.RawPosting filter(Inverted.Layouts.RawPosting doc) := TRANSFORM
 
 

SELF.term:=REGEXREPLACE( expr,doc.term,STD.Uni.FilterOut(doc.term, '.'));
 SELF := doc;
END;

 
enumDocs    := Inverted.EnumeratedDocs(info,  inDocs);
p1 := Inverted.ParsedText(enumDocs);
rawPostings := Inverted.RawPostings(enumDocs);

OUTPUT(rawPostings,,'~ONLINE::Farah::OUT::Solution1',OVERWRITE);

//s:= PROJECT(rawPostings, filter(LEFT));

//OUTPUT(s,,'~ONLINE::Farah::OUT::Solution2',OVERWRITE);

/*IMPORT Std;
ds := DATASET([{'2 A.B.C'},
               {'3 C.C.D'},
               {'4 D.D'}],{STRING indata});*/
ValRec := RECORD
  unicode val;
END;   
DNrec := RECORD
  UNSIGNED4 RecID;
  DATASET(ValRec) Values;
END;

DNrec XF(rawPostings L) := TRANSFORM
  SpacePos    := Std.Uni.Find(L.term,' ',1);
  //SetStrVals  := Std.Str.SplitWords((STRING)L.term[SpacePos+1..],'')+Std.Str.SplitWords((STRING)L.term[SpacePos+1..],'.');
	SetStrVals  := REGEXFINDSET(expr2,(STRING)L.term)+Std.Str.SplitWords((STRING)L.term[SpacePos+1..],'.');
	 
	//r:=(STD.Str.FilterOut((STRING)L.term,'.'));
	
 	//SetStrVals  := REGEXFINDSET(expr2,(STRING)L.term)+Std.Str.SplitWords((STRING)L.term[SpacePos+1..],'.')+r;


  ValuesDS    := DATASET(SetStrVals,{STRING StrVal});
  SELF.RecID  := (UNSIGNED4)L.term[1..SpacePos];
  SELF.Values := PROJECT(ValuesDS,
                         TRANSFORM(ValRec,
                                   SELF.val := (unicode)Left.StrVal));
END;
NestedDS := PROJECT(rawPostings,XF(LEFT));   
NestedDS;

OutRec := RECORD
  UNSIGNED RecID;
  unicode val;
END;

res:=NORMALIZE(NestedDS,COUNT(LEFT.Values),
          TRANSFORM(OutRec,
                    SELF.val := LEFT.Values[COUNTER].val,
                    SELF := LEFT));
										
output(res);
	
	
//d := DEDUP(res,LEFT.val = RIGHT.val);
//OUTPUT(d);
 
 	//c:=REGEXFINDSET(expr,doc.content);
	
	