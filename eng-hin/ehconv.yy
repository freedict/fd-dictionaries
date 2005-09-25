/*

* Example entries from the isc file:

"after","Prep","1.³á~ÊÚÄ"
We shall meet here the day after tomarrow.
Day after day I tried to meet him but could not.
My name comes after yours in the roll call.
After all your ill conduct, I do not wish to speak to you.
She arrived just after lunch.
--"2.³Ü~°Ï"
The children stared after the detectives dressed 
I ran after him to tell him to meet me later.
I'm after a job in the hospital.
--"3.³á~ÊÚÏá~Ìá¢"
I inquired after him and come to know that he was ill.
--"4.³á~¤Æİ×ÏÁ~ÈÏ"
He was named after his grandfather and really emerged just like him.

"after","Adj","1.ÊÚÄ~³Ú"
We shall rectify these problems in the after years.

* Sometimes there are malformed entries:

"abstract","V","1.Ø½Ú~ÑáÆÚ"
Two other points must be abstracted to the lecture.
--"2."×¢³èÖÛÈèÂ~ÊÆÚÆÚ/×¢³èÖáÈ~³ÏÆÚ"
Most of the famous novels are abstracted.

(The third line has a quote sign too much.)

* There are bytes in the hindi that are not explained
by the ISCII-1991 standard: 237 and 254.

* The empty line separating entries sometimes contains whitespace.

* Sometimes there are 3 minus signs indicating
  alternatives instead of 2 only.

* Sometimes even missing final quotes (need to be corrected in the input file):

"depress","VT","1.ÄÊÚÆÚ"
The glut of oil depressed gas prices
--"2.¨ÄÚ× ³ÏÆÚ
These news depressed her
--"3.³Ì ³ÏÆÚ
The lack of rain had depressed the water level in the reservoir
--"4.ÌÆèÄ ³ÏÆÚ
The rising inflation depressed the economy

* Sometimes missing "1." indicating the definition number:

"haltingly","Adv","ÔÛÏÑ ×á ÊåÑÆá ÔÚÑÚ"
¨Ìá× ³Ü ºÊÚÆ"haltingly"ºÆèÌ ×á ØÜ Øâ. 

* Sometimes space follows the final quoatation mark in a line:
  (third line here):

"crave","VT","1.ÑÚÑ×Ú~³ÏÆÚ/¤ËÛÑÚÖÚ~³ÏÆÚ"
In my childhood,I craved for my parent's attention.
--"2.ÍÚ¸ÆÚ~³ÏÆÚ"  
She craved for her husband's life. 

* Sometimes the definition is missing:

"clonk","N","1."
I could hear the clonk of aircrafts.

These entries in the source file got a comment
added saying "# definition missing".

* sometimes example sentences span two lines - it's
  'impossible' for the scanner to spell this apart from
  two ex. sentences.

* Sometimes after a DEFINITION the lines contain #-comments.
  They don't get translated into the XML file!

"cloze test","N","1.³èÑåºé~½á×è½" #ÏÛ³èÂ~×èÃÚÆå~³Ü~ÈŞÏèÂÜ~×ØÜ~ÕÊèÄå~×á~³ÏÆá~³Ü~ÈÏÜ³èÖÚ
We had to take a cloze test before joining the English teaching course.

* Are there superfluous spaces after the definition sometimes?

"stern","Adj","1.³¾åÏ ÍÚ ÆÛÏèÄÍ"
Hotler was a stern man.
--"2.ºéØÚºé ³Ú ÈÛ¹ÑÚ ËÚµ'     "
When an iceberg was seen in front of a ship, people tried to escape from the stern part.

* Sometimes the source file contains malformed entries
  where there comes a quote directly after the
  alternative number:

"weighed-anchor","V","1.ÈÚÆÜ ×á Ñ¢µÏ ¨¾Ú ÑáÆÚ ±Ï ºÚÆá ³á ÑÛ¬ ÂâÍÚÏ ÏØÆÚ"
The steamer blow a whistle and weighed anchor to start.
--"2."×ØÍåµ/×ØÚÏÚ"
Without the anchor of his wife's support,he couldn't have been successful.

--------

* Sometimes the translation has alternatives separated by "/"
 -> is translated into several <tr>-Elements

"absurd","Adj","1.ÆÛÏÏèÃ³/ÊáÂİ³Ú"
I find his ideas absurd.
--"2.ÌŞÏè´/ÊİÄèÅÛÏŞÄèÅ"
That dress makes them look absurd.

* standardize POS contents

* sometimes the example sentence is in Hindi.

"author","N","1.Ñá´³"
Shakespeare is my favorite author.
Õá³è×ÈÛÍÏ ÌáÏá ÈèÏÛÍ Ñá´³ Øâ.
--"2.ÈèÏÔÏèÂ³ "
Ram is the author of the proposal so he can't comment.
ÏÚÌ ¦× ÈèÏ×èÂÚÔ ³Ú ÈèÏÔÏèÂ³ Øâ ¤Â: ÔØ ½ÛÈèÈÁÜ ÆØÜ¢ ³Ï ×³ÂÚ .

--------

*/
%option yylineno
%s HEADWORD POS DEFINITION DE1 EXAMPLE EX1 ALTERNATIVE

	int num_entries = 0;

	void printEscaped(char *str) {
	  while (*str != '\0') {
		 switch(*str) {
		 case '"': printf("&quot;"); break;
		 case '&': printf("&amp;"); break;
		 case '<': printf("&lt;"); break;
		 case '>': printf("&gt;"); break;
		 case '`': printf("&lsquo;"); break;
	     case '’': printf("&rsquo;"); break;
		 default:
		  if(*str>128) fprintf(stderr,"Don't know how to escape '%c'",*str);
		  putchar(*str);
		 }
	  str++;
	  }
	}

	void printfIscii2Utf8(char *str) {
     unsigned char u8[3],c,s[]=" ";
	 int u;

     if(0==strncmp("Liberty to hold one",str,19))
      fprintf(stderr,"yylineno: %i '%s' %hu\n",yylineno,str,(*(str+19) & 255));

	 while (*str != '\0') {
      c = *str;

	  //printf("%i\n",c);

	  // Iscii-1991 -> UCS-2

	  if(c<0x80) u = c;
	  else if (c=='`') u=0x2018;
      else if (c=='’') u=0x2019;
      else if (c==146) u=0x2019;
	  else if(c<0xa0) {
	    fprintf(stderr,"problem char: %c",c);
	    u = c;}
	  else switch(c) {
		  case 0xa1: 
		  case 0xa2:
		  case 0xa3:u=0x900+c-0xa0; break;
		  case 0xa4:
		  case 0xa5:
		  case 0xa6:
		  case 0xa7:
		  case 0xa8:
		  case 0xa9:
		  case 0xaa:u=0x900+c-0x9f; break;
		  case 0xab:u=0x90e; break;
		  case 0xac:u=0x90f; break;
		  case 0xad:u=0x910; break;
		  case 0xae:u=0x90d; break;
		  case 0xaf:u=0x912; break;

		  case 0xb0:u=0x913; break;
		  case 0xb1:u=0x914; break;
		  case 0xb2:u=0x911; break;
		  case 0xb3:u=0x915; break;
		  case 0xb4:
		  case 0xb5:
		  case 0xb6:
		  case 0xb7:
		  case 0xb8:
		  case 0xb9:
		  case 0xba:
		  case 0xbb:
		  case 0xbc:
		  case 0xbd:
		  case 0xbe:
		  case 0xbf:

		  case 0xc0:
		  case 0xc1:
		  case 0xc2:
		  case 0xc3:
		  case 0xc4:
		  case 0xc5:
		  case 0xc6:
		  case 0xc7:
		  case 0xc8:
		  case 0xc9:
		  case 0xca:
		  case 0xcb:
		  case 0xcc:
		  case 0xcd:u=0x900+c-0x9e; break;// should become 0x92f
		  case 0xce:u=0x95f; break;
		  case 0xcf:

		  case 0xd0:
		  case 0xd1:
		  case 0xd2:
		  case 0xd3:
		  case 0xd4:
		  case 0xd5:
		  case 0xd6:
		  case 0xd7:
		  case 0xd8:u=0x900+c-0x9f;break;// should become 0x939

		  case 0xda:
		  case 0xdb:
		  case 0xdc:
		  case 0xdd:
		  case 0xde:
		  case 0xdf:u=0x900+c-0x9c;break;// should become 0x943

		  case 0xe0:
		  case 0xe1:
		  case 0xe2:u=0x900+c-0x9a;break;// should become 0x948
		  case 0xe3:u=0x945; break;
		  case 0xe4:
		  case 0xe5:
		  case 0xe6:u=0x900+c-0x9a;break;// should become 0x94c
		  case 0xe7:u=0x949; break;
		  case 0xe8:u=0x94d; break;
		  case 0xe9:u=0x93c; break;
		  case 0xea:u=0x964; break;

		  case 0xf1:
		  case 0xf2:
		  case 0xf3:
		  case 0xf4:
		  case 0xf5:
		  case 0xf6:
		  case 0xf7:
		  case 0xf8:
		  case 0xf9:
		  case 0xfa:u=0x900+c-0x8b; break;// should become 0x96f

		  case 0xfb:
		  case 0xfc:
		  case 0xfd:
		  case 0xfe:
		  case 0xff:
		  case 0xf0:
		  case 0xeb:
		  case 0xec:
		  case 0xed:
		  case 0xee:
		  case 0xef:
		  case 0xd9:
		  case 0xa0:
		  default: fprintf(stderr,"line %i: not my iscii range: %i\n",yylineno,c);u='?';
	  };

	  // UCS-2 -> Utf8:
	  if(u>0xefff) { fprintf(stderr,"not my utf8 range");exit(1); }
	  if(u<0x80) { s[0]=u;s[1]=0;printEscaped(s);
	    if(u=='’') fprintf(stderr,"%c",s[0]);
	    // so we don't just output utf8, but even
	    // escape some sgml specific chars
	    }
      else if(u<0x800) {
        // 00000yyy yyxxxxxx -> 110yyyyy 10xxxxxx 
	    u8[0] = 0xc0 | ((u>>6) & 0x1f);
	    u8[1] = 0x80 | (u  & 0x3f);
		printf("%c%c",u8[0],u8[1]);
	  }
	  else {

	    // zzzzyyyy yyxxxxxx -> 1110zzzz 10yyyyyy 10xxxxxx 
	    u8[0] = 0xe0 | ((u>>12) & 0xf);
	    u8[1] = 0x80 | ((u>>6)  & 0x3f);
	    u8[2] = 0x80 | (u  & 0x3f);

		//printf("(%x %x %x)",u8[0],u8[1],u8[2]);
		printf("%c%c%c",u8[0],u8[1],u8[2]);
	  }
	  str++;
	  }
	 }

OPTCOMMENT	("#"[^\n]*)?
WHITESPACE	[ \t]*
%%

<INITIAL>\"			printf("<entry>\n"); BEGIN(HEADWORD);

<HEADWORD>[^"]+			printf(" <form><orth>%s</orth></form>\n",yytext);
<HEADWORD>\",\"			BEGIN(POS);

<POS>[^"]+				printf(" <gramGrp><pos>%s</pos></gramGrp>\n",yytext);
<POS>\",\"[1-9]\.		{
		printf(" <sense n=\"%c\">\n  <trans>",yytext[3]); BEGIN(DEFINITION);
		}
<POS>\",\"			{
		printf(" <sense n=\"1\">\n  <trans>"); BEGIN(DEFINITION);
		}

<DEFINITION>[^\"/]+\/		{
		printf("<tr>");
		yytext[yyleng-1]='\0';// remove trailing '/'
		printfIscii2Utf8(yytext);
		printf("</tr>");
		}

<DEFINITION>[^\"/]+/\"		{
		printf("<tr>");
		printfIscii2Utf8(yytext);
		printf("</tr></trans>\n");
		BEGIN(DE1);
		}

<DE1>\"{WHITESPACE}{OPTCOMMENT}\n	BEGIN(EXAMPLE);
<DE1>\"{WHITESPACE}{OPTCOMMENT}/\n{WHITESPACE}\n	BEGIN(EX1);

<EXAMPLE>[^\n]+			{
		printf("  <eg><q>");
	        /* special chars like " and & also get encoded! */
		printfIscii2Utf8(yytext);
		printf("</q></eg>\n"); BEGIN(EX1);
		}

<EX1>\n--\"[1-9]\.		{
    		printf(" </sense>\n <sense n='%c'>\n  <trans>",yytext[4]);
		BEGIN(DEFINITION);// Alternative
		}
<EX1>\n---\"[1-9]\.		{
	        printf(" </sense>\n <sense n='%c'>\n  <trans>",yytext[5]);
		BEGIN(DEFINITION);// Alternative
		}
<EX1>\n{WHITESPACE}\n		{
		printf(" </sense>\n </entry>\n\n"); num_entries++;
		if(num_entries) BEGIN(INITIAL);
		else return 0;
		}
<EX1>\n				BEGIN(EXAMPLE);

<<EOF>>				printf(" </sense>\n </entry>\n"); yyterminate();

.				{
    		fprintf(stderr, "Malformed input in line %i: %s\n",yylineno,yytext); }

%%
int main() {
	yylex();
	printf("</body></text></TEI.2>\n");
	fprintf(stderr, "# of entries = %d\n", num_entries );
	return 0;
	}
