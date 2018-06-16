
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




 
enumDocs    := Inverted.EnumeratedDocs(info,  inDocs);
p1 := Inverted.ParsedText(enumDocs);
rawPostings := Inverted.RawPostings(enumDocs);

OUTPUT(rawPostings,,'~ONLINE::Farah::OUT::Solution1',OVERWRITE);


ValRec := RECORD
  unicode val;
END;   
DNrec := RECORD
	RawPostings ;
  DATASET(ValRec) Values;
END;

DNrec filter(rawPostings L) := TRANSFORM
  //SpacePos    := Std.Uni.Find(L.term,' ',1);
  //SetStrVals  := Std.Str.SplitWords((STRING)L.term[SpacePos+1..],'')+Std.Str.SplitWords((STRING)L.term[SpacePos+1..],'.');
	SetStrVals  := REGEXFINDSET(expr2,(STRING)L.term)+Std.Str.SplitWords((STRING)L.term,'.');
	 	//SetStrVals  := REGEXFINDSET(expr2,(STRING)L.term)+Std.Str.SplitWords((STRING)L.term[SpacePos+1..],'.');

	//r:=(STD.Str.FilterOut((STRING)L.term,'.'));
	
 	//SetStrVals  := REGEXFINDSET(expr2,(STRING)L.term)+Std.Str.SplitWords((STRING)L.term[SpacePos+1..],'.')+r;


  ValuesDS    := DATASET(SetStrVals,{STRING StrVal});

  SELF.Values := PROJECT(ValuesDS,
                         TRANSFORM(ValRec,
                                   SELF.val := (unicode)Left.StrVal));
	 
																	  
  SELF.id:=L.id;
	SELF.kwp:=L.kwp+1;
	SELF.start:=L.start;
	SELF.stop:=L.stop;
	SELF.depth:=L.depth;
	SELF.len:=L.len;
	SELF.lentext:=L.lentext;
	//SELF.keywords:=if(length(L.term)=1,1,L.keywords);
	SELF.keywords:=L.keywords;
	SELF.typterm:=L.typterm;
	SELF.typdata:=L.typdata;
  SELF.preorder:=L.preorder;     
  SELF.parentOrd:=L.parentOrd;    
  SELF.lp:=L.lp;
  SELF.tagName:=L.tagName;
  SELF.term:=L.term;
  SELF.tagValue:=L.tagValue;
  SELF.pathString:=L.pathString;
  SELF.parentName:=L.parentName;	


	
END;
NestedDS := PROJECT(rawPostings,filter(LEFT));   
NestedDS;

OutRec := RECORD
		RawPostings;
		 unicode val;

END;

res:=NORMALIZE(NestedDS,COUNT(LEFT.Values),
          TRANSFORM(OutRec,
                    SELF.val := LEFT.Values[COUNTER].val,Self.term:=LEFT.Values[COUNTER].val,SELF.len:=length(LEFT.Values[COUNTER].val),SELF.kwp:=LEFT.kwp+COUNTER,SELF.keywords:=if(length(LEFT.Values[COUNTER].val)=1,1,LEFT.keywords)
										,SELF.lentext:=length(LEFT.Values[COUNTER].val),SELF.typterm:=if(length(LEFT.Values[COUNTER].val)=1,1,LEFT.typterm);
                    SELF := LEFT,
	
										 ));
										
output(res);
	
	
