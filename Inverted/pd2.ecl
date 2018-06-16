//EXPORT pd2 := 'todo';
// Parse contents of the document
IMPORT TextSearch2;
IMPORT TextSearch2.Common;
IMPORT TextSearch2.Inverted.Layouts;
IMPORT STD;
Document := Layouts.Document;
RawPosting := Layouts.RawPosting;
Types := Common.Types;
Constants := Common.Constants;

EXPORT DATASET(RawPosting) ParsedText(RawPosting docsInput) := FUNCTION
  // Tokenize content
  Common.Pattern_Definitions()
  PATTERN TagEndSeq     := U'/>' OR U'>';
  PATTERN Equals        := OPT(Spaces) U'=' OPT(Spaces);
  PATTERN StartNameChar	:= Letter OR Colon OR Underscore;
  PATTERN NameChar			:= StartNameChar OR Hyphen OR Period OR Digit OR MidDot;
  PATTERN XMLName				:= StartNameChar NameChar*;
  PATTERN EndElement    := U'</' OPT(Spaces) XMLName OPT(Spaces) U'>';
  PATTERN AnyNoAposStr  := AnyNoApos+;
  PATTERN AposValueWrap := '\'' OPT(AnyNoAposStr) '\'';
  PATTERN AnyNoQuoteStr := AnyNoQuote+;
  PATTERN QuotValueWrap := '"' OPT(AnyNoQuoteStr) '"';
  PATTERN ValueExpr     := Equals (AposValueWrap OR QuotValueWrap);
  PATTERN EmptyAttribute:= Spaces  XMLName NOT BEFORE ValueExpr;
  PATTERN ValueAttribute:= Spaces  XMLName ValueExpr;
  PATTERN AttrListItem  := EmptyAttribute OR ValueAttribute;
  PATTERN AttributeList := REPEAT(AttrListItem) OPT(Spaces) TagEndSeq;
  PATTERN AttributeExpr := AttrListItem BEFORE AttributeList;
  PATTERN XMLComment    := U'<!--' (AnyNoHyphen OR (U'-' AnyNoHyphen))* U'-->';
  PATTERN VersionInfo   := U'version' OPT(Spaces) ValueExpr;
  PATTERN EncodingInfo  := U'encoding' OPT(Spaces) ValueExpr;
  PATTERN SDDecl        := U'standalone' OPT(Spaces) ValueExpr;
  PATTERN XMLDecl       := U'<?xml' Spaces VersionInfo
                           OPT(Spaces EncodingInfo) OPT(Spaces EncodingInfo)
                           OPT(Spaces SDDecl) OPT(Spaces) U'?>';
  PATTERN ContainerEnd  := REPEAT(AttrListItem) OPT(Spaces) U'>';
  PATTERN EmptyEnd      := REPEAT(AttrListItem) OPT(Spaces) U'/>';
  PATTERN XMLElement    := U'<' XMLName BEFORE ContainerEnd;
  PATTERN XMLEmpty      := U'<' XMLName BEFORE EmptyEnd;
	PATTERN expr2 :=PATTERN(U'[a-zA-Z][.][a-zA-Z]*[.][a-zA-Z]*[.]*[a-zA-Z]*');//new addition
	PATTERN expr3 :=PATTERN(U'[a-zA-Z][.][a-zA-Z]*');//new addition
//Pattern init  :=VALIDATE(PATTERN('[A-Za-z]+'), MATCHTEXT != '.');



//PATTERN init:=PATTERN('[a-zA-Z][.][a-zA-Z]*[.][a-zA-Z]*[.]*[a-zA-Z]*');
PATTERN alpha := PATTERN('[A-Za-z]+');
PATTERN ws := [' ']*;
 
 


 
//rule r :=   expr2 ws or alpha;

 

//ps1 := { 

//out1 := MATCHTEXT(r) }; 

 


  RULE myRule           :=  expr2 ws or alpha expr2 or expr3  OR XMLDecl OR XMLComment OR XMLElement OR XMLEmpty OR
                           AttributeExpr OR EndElement OR TagEndSeq OR
                           WordAlphaNum OR WhiteSpace OR PoundCode OR
                           SymbolChar OR Noise OR AnyChar OR AnyPair ;//or NoHenWord | Article ws Word;//update




  p0 := PARSE(docsInput, docsInput.term, myRule, parseString(LEFT), MAX, MANY, NOT MATCHED);
 //p1 := ASSERT(p0, typTerm<>Types.TermType.Unknown, Constants.OtherCharsInText_Msg);
  RETURN p0(typTerm <> Types.TermType.WhiteSpace);// change p1 to p0 here 
 //Return p0;//addition
END;