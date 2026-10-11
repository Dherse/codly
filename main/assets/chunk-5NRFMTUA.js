import{h as Ut}from"./chunk-DKPAWHBW.js";import{a as Wt}from"./chunk-ECZVYQKE.js";import{b as Mt}from"./chunk-Q4UVGCGF.js";import{a as jt}from"./chunk-5ZPVCWNG.js";import{g as Gt,p as Vt}from"./chunk-MNCGMG7K.js";import{N as M,T as Nt,U as Rt,V as $t,W as Ft,X as Pt,Y as Bt,Z as Yt,_ as R,g as Ot}from"./chunk-H6HJX7CE.js";import{b as E,h as pt}from"./chunk-BG5BKATX.js";import{a as f}from"./chunk-YUSHYV7C.js";var Ct=(function(){var t=f(function(V,a,u,i){for(u=u||{},i=V.length;i--;u[V[i]]=a);return u},"o"),e=[1,2],l=[1,3],s=[1,4],c=[2,4],h=[1,9],p=[1,11],y=[1,16],o=[1,17],T=[1,18],m=[1,19],O=[1,33],x=[1,20],_=[1,21],d=[1,22],L=[1,23],$=[1,24],C=[1,26],F=[1,27],A=[1,28],P=[1,29],I=[1,30],H=[1,31],rt=[1,32],it=[1,35],at=[1,36],nt=[1,37],ot=[1,38],z=[1,34],S=[1,4,5,16,17,19,21,22,24,25,26,27,28,29,33,35,37,38,41,45,48,51,52,53,54,57],lt=[1,4,5,14,15,16,17,19,21,22,24,25,26,27,28,29,33,35,37,38,39,40,41,45,48,51,52,53,54,57],Lt=[4,5,16,17,19,21,22,24,25,26,27,28,29,33,35,37,38,41,45,48,51,52,53,54,57],Tt={trace:f(function(){},"trace"),yy:{},symbols_:{error:2,start:3,SPACE:4,NL:5,SD:6,document:7,line:8,statement:9,classDefStatement:10,styleStatement:11,cssClassStatement:12,idStatement:13,DESCR:14,"-->":15,HIDE_EMPTY:16,scale:17,WIDTH:18,COMPOSIT_STATE:19,STRUCT_START:20,STRUCT_STOP:21,STATE_DESCR:22,AS:23,ID:24,FORK:25,JOIN:26,CHOICE:27,CONCURRENT:28,note:29,notePosition:30,NOTE_TEXT:31,direction:32,acc_title:33,acc_title_value:34,acc_descr:35,acc_descr_value:36,acc_descr_multiline_value:37,CLICK:38,STRING:39,HREF:40,classDef:41,CLASSDEF_ID:42,CLASSDEF_STYLEOPTS:43,DEFAULT:44,style:45,STYLE_IDS:46,STYLEDEF_STYLEOPTS:47,class:48,CLASSENTITY_IDS:49,STYLECLASS:50,direction_tb:51,direction_bt:52,direction_rl:53,direction_lr:54,eol:55,";":56,EDGE_STATE:57,STYLE_SEPARATOR:58,left_of:59,right_of:60,$accept:0,$end:1},terminals_:{2:"error",4:"SPACE",5:"NL",6:"SD",14:"DESCR",15:"-->",16:"HIDE_EMPTY",17:"scale",18:"WIDTH",19:"COMPOSIT_STATE",20:"STRUCT_START",21:"STRUCT_STOP",22:"STATE_DESCR",23:"AS",24:"ID",25:"FORK",26:"JOIN",27:"CHOICE",28:"CONCURRENT",29:"note",31:"NOTE_TEXT",33:"acc_title",34:"acc_title_value",35:"acc_descr",36:"acc_descr_value",37:"acc_descr_multiline_value",38:"CLICK",39:"STRING",40:"HREF",41:"classDef",42:"CLASSDEF_ID",43:"CLASSDEF_STYLEOPTS",44:"DEFAULT",45:"style",46:"STYLE_IDS",47:"STYLEDEF_STYLEOPTS",48:"class",49:"CLASSENTITY_IDS",50:"STYLECLASS",51:"direction_tb",52:"direction_bt",53:"direction_rl",54:"direction_lr",56:";",57:"EDGE_STATE",58:"STYLE_SEPARATOR",59:"left_of",60:"right_of"},productions_:[0,[3,2],[3,2],[3,2],[7,0],[7,2],[8,2],[8,1],[8,1],[9,1],[9,1],[9,1],[9,1],[9,2],[9,3],[9,4],[9,1],[9,2],[9,1],[9,4],[9,3],[9,6],[9,1],[9,1],[9,1],[9,1],[9,4],[9,4],[9,1],[9,2],[9,2],[9,1],[9,5],[9,5],[10,3],[10,3],[11,3],[12,3],[32,1],[32,1],[32,1],[32,1],[55,1],[55,1],[13,1],[13,1],[13,3],[13,3],[30,1],[30,1]],performAction:f(function(a,u,i,g,b,r,K){var n=r.length-1;switch(b){case 3:return g.setRootDoc(r[n]),r[n];break;case 4:this.$=[];break;case 5:r[n]!="nl"&&(r[n-1].push(r[n]),this.$=r[n-1]);break;case 6:case 7:this.$=r[n];break;case 8:this.$="nl";break;case 12:this.$=r[n];break;case 13:let ht=r[n-1];ht.description=g.trimColon(r[n]),this.$=ht;break;case 14:this.$={stmt:"relation",state1:r[n-2],state2:r[n]};break;case 15:let ut=g.trimColon(r[n]);this.$={stmt:"relation",state1:r[n-3],state2:r[n-1],description:ut};break;case 19:this.$={stmt:"state",id:r[n-3],type:"default",description:"",doc:r[n-1]};break;case 20:var B=r[n],Y=r[n-2].trim();if(r[n].match(":")){var Q=r[n].split(":");B=Q[0],Y=[Y,Q[1]]}this.$={stmt:"state",id:B,type:"default",description:Y};break;case 21:this.$={stmt:"state",id:r[n-3],type:"default",description:r[n-5],doc:r[n-1]};break;case 22:this.$={stmt:"state",id:r[n],type:"fork"};break;case 23:this.$={stmt:"state",id:r[n],type:"join"};break;case 24:this.$={stmt:"state",id:r[n],type:"choice"};break;case 25:this.$={stmt:"state",id:g.getDividerId(),type:"divider"};break;case 26:this.$={stmt:"state",id:r[n-1].trim(),note:{position:r[n-2].trim(),text:r[n].trim()}};break;case 29:this.$=r[n].trim(),g.setAccTitle(this.$);break;case 30:case 31:this.$=r[n].trim(),g.setAccDescription(this.$);break;case 32:this.$={stmt:"click",id:r[n-3],url:r[n-2],tooltip:r[n-1]};break;case 33:this.$={stmt:"click",id:r[n-3],url:r[n-1],tooltip:""};break;case 34:case 35:this.$={stmt:"classDef",id:r[n-1].trim(),classes:r[n].trim()};break;case 36:this.$={stmt:"style",id:r[n-1].trim(),styleClass:r[n].trim()};break;case 37:this.$={stmt:"applyClass",id:r[n-1].trim(),styleClass:r[n].trim()};break;case 38:g.setDirection("TB"),this.$={stmt:"dir",value:"TB"};break;case 39:g.setDirection("BT"),this.$={stmt:"dir",value:"BT"};break;case 40:g.setDirection("RL"),this.$={stmt:"dir",value:"RL"};break;case 41:g.setDirection("LR"),this.$={stmt:"dir",value:"LR"};break;case 44:case 45:this.$={stmt:"state",id:r[n].trim(),type:"default",description:""};break;case 46:this.$={stmt:"state",id:r[n-2].trim(),classes:[r[n].trim()],type:"default",description:""};break;case 47:this.$={stmt:"state",id:r[n-2].trim(),classes:[r[n].trim()],type:"default",description:""};break}},"anonymous"),table:[{3:1,4:e,5:l,6:s},{1:[3]},{3:5,4:e,5:l,6:s},{3:6,4:e,5:l,6:s},t([1,4,5,16,17,19,22,24,25,26,27,28,29,33,35,37,38,41,45,48,51,52,53,54,57],c,{7:7}),{1:[2,1]},{1:[2,2]},{1:[2,3],4:h,5:p,8:8,9:10,10:12,11:13,12:14,13:15,16:y,17:o,19:T,22:m,24:O,25:x,26:_,27:d,28:L,29:$,32:25,33:C,35:F,37:A,38:P,41:I,45:H,48:rt,51:it,52:at,53:nt,54:ot,57:z},t(S,[2,5]),{9:39,10:12,11:13,12:14,13:15,16:y,17:o,19:T,22:m,24:O,25:x,26:_,27:d,28:L,29:$,32:25,33:C,35:F,37:A,38:P,41:I,45:H,48:rt,51:it,52:at,53:nt,54:ot,57:z},t(S,[2,7]),t(S,[2,8]),t(S,[2,9]),t(S,[2,10]),t(S,[2,11]),t(S,[2,12],{14:[1,40],15:[1,41]}),t(S,[2,16]),{18:[1,42]},t(S,[2,18],{20:[1,43]}),{23:[1,44]},t(S,[2,22]),t(S,[2,23]),t(S,[2,24]),t(S,[2,25]),{30:45,31:[1,46],59:[1,47],60:[1,48]},t(S,[2,28]),{34:[1,49]},{36:[1,50]},t(S,[2,31]),{13:51,24:O,57:z},{42:[1,52],44:[1,53]},{46:[1,54]},{49:[1,55]},t(lt,[2,44],{58:[1,56]}),t(lt,[2,45],{58:[1,57]}),t(S,[2,38]),t(S,[2,39]),t(S,[2,40]),t(S,[2,41]),t(S,[2,6]),t(S,[2,13]),{13:58,24:O,57:z},t(S,[2,17]),t(Lt,c,{7:59}),{24:[1,60]},{24:[1,61]},{23:[1,62]},{24:[2,48]},{24:[2,49]},t(S,[2,29]),t(S,[2,30]),{39:[1,63],40:[1,64]},{43:[1,65]},{43:[1,66]},{47:[1,67]},{50:[1,68]},{24:[1,69]},{24:[1,70]},t(S,[2,14],{14:[1,71]}),{4:h,5:p,8:8,9:10,10:12,11:13,12:14,13:15,16:y,17:o,19:T,21:[1,72],22:m,24:O,25:x,26:_,27:d,28:L,29:$,32:25,33:C,35:F,37:A,38:P,41:I,45:H,48:rt,51:it,52:at,53:nt,54:ot,57:z},t(S,[2,20],{20:[1,73]}),{31:[1,74]},{24:[1,75]},{39:[1,76]},{39:[1,77]},t(S,[2,34]),t(S,[2,35]),t(S,[2,36]),t(S,[2,37]),t(lt,[2,46]),t(lt,[2,47]),t(S,[2,15]),t(S,[2,19]),t(Lt,c,{7:78}),t(S,[2,26]),t(S,[2,27]),{5:[1,79]},{5:[1,80]},{4:h,5:p,8:8,9:10,10:12,11:13,12:14,13:15,16:y,17:o,19:T,21:[1,81],22:m,24:O,25:x,26:_,27:d,28:L,29:$,32:25,33:C,35:F,37:A,38:P,41:I,45:H,48:rt,51:it,52:at,53:nt,54:ot,57:z},t(S,[2,32]),t(S,[2,33]),t(S,[2,21])],defaultActions:{5:[2,1],6:[2,2],47:[2,48],48:[2,49]},parseError:f(function(a,u){if(u.recoverable)this.trace(a);else{var i=new Error(a);throw i.hash=u,i}},"parseError"),parse:f(function(a){var u=this,i=[0],g=[],b=[null],r=[],K=this.table,n="",B=0,Y=0,Q=0,ht=2,ut=1,fe=r.slice.call(arguments,1),k=Object.create(this.lexer),W={yy:{}};for(var bt in this.yy)Object.prototype.hasOwnProperty.call(this.yy,bt)&&(W.yy[bt]=this.yy[bt]);k.setInput(a,W.yy),W.yy.lexer=k,W.yy.parser=this,typeof k.yylloc>"u"&&(k.yylloc={});var Et=k.yylloc;r.push(Et);var pe=k.options&&k.options.ranges;typeof W.yy.parseError=="function"?this.parseError=W.yy.parseError:this.parseError=Object.getPrototypeOf(this).parseError;function Se(w){i.length=i.length-2*w,b.length=b.length-w,r.length=r.length-w}f(Se,"popStack");function It(){var w;return w=g.pop()||k.lex()||ut,typeof w!="number"&&(w instanceof Array&&(g=w,w=g.pop()),w=u.symbols_[w]||w),w}f(It,"lex");for(var D,mt,j,N,Ve,kt,X={},dt,G,wt,ft;;){if(j=i[i.length-1],this.defaultActions[j]?N=this.defaultActions[j]:((D===null||typeof D>"u")&&(D=It()),N=K[j]&&K[j][D]),typeof N>"u"||!N.length||!N[0]){var _t="";ft=[];for(dt in K[j])this.terminals_[dt]&&dt>ht&&ft.push("'"+this.terminals_[dt]+"'");k.showPosition?_t="Parse error on line "+(B+1)+`:
`+k.showPosition()+`
Expecting `+ft.join(", ")+", got '"+(this.terminals_[D]||D)+"'":_t="Parse error on line "+(B+1)+": Unexpected "+(D==ut?"end of input":"'"+(this.terminals_[D]||D)+"'"),this.parseError(_t,{text:k.match,token:this.terminals_[D]||D,line:k.yylineno,loc:Et,expected:ft})}if(N[0]instanceof Array&&N.length>1)throw new Error("Parse Error: multiple actions possible at state: "+j+", token: "+D);switch(N[0]){case 1:i.push(D),b.push(k.yytext),r.push(k.yylloc),i.push(N[1]),D=null,mt?(D=mt,mt=null):(Y=k.yyleng,n=k.yytext,B=k.yylineno,Et=k.yylloc,Q>0&&Q--);break;case 2:if(G=this.productions_[N[1]][1],X.$=b[b.length-G],X._$={first_line:r[r.length-(G||1)].first_line,last_line:r[r.length-1].last_line,first_column:r[r.length-(G||1)].first_column,last_column:r[r.length-1].last_column},pe&&(X._$.range=[r[r.length-(G||1)].range[0],r[r.length-1].range[1]]),kt=this.performAction.apply(X,[n,Y,B,W.yy,N[1],b,r].concat(fe)),typeof kt<"u")return kt;G&&(i=i.slice(0,-1*G*2),b=b.slice(0,-1*G),r=r.slice(0,-1*G)),i.push(this.productions_[N[1]][0]),b.push(X.$),r.push(X._$),wt=K[i[i.length-2]][i[i.length-1]],i.push(wt);break;case 3:return!0}}return!0},"parse")},de=(function(){var V={EOF:1,parseError:f(function(u,i){if(this.yy.parser)this.yy.parser.parseError(u,i);else throw new Error(u)},"parseError"),setInput:f(function(a,u){return this.yy=u||this.yy||{},this._input=a,this._more=this._backtrack=this.done=!1,this.yylineno=this.yyleng=0,this.yytext=this.matched=this.match="",this.conditionStack=["INITIAL"],this.yylloc={first_line:1,first_column:0,last_line:1,last_column:0},this.options.ranges&&(this.yylloc.range=[0,0]),this.offset=0,this},"setInput"),input:f(function(){var a=this._input[0];this.yytext+=a,this.yyleng++,this.offset++,this.match+=a,this.matched+=a;var u=a.match(/(?:\r\n?|\n).*/g);return u?(this.yylineno++,this.yylloc.last_line++):this.yylloc.last_column++,this.options.ranges&&this.yylloc.range[1]++,this._input=this._input.slice(1),a},"input"),unput:f(function(a){var u=a.length,i=a.split(/(?:\r\n?|\n)/g);this._input=a+this._input,this.yytext=this.yytext.substr(0,this.yytext.length-u),this.offset-=u;var g=this.match.split(/(?:\r\n?|\n)/g);this.match=this.match.substr(0,this.match.length-1),this.matched=this.matched.substr(0,this.matched.length-1),i.length-1&&(this.yylineno-=i.length-1);var b=this.yylloc.range;return this.yylloc={first_line:this.yylloc.first_line,last_line:this.yylineno+1,first_column:this.yylloc.first_column,last_column:i?(i.length===g.length?this.yylloc.first_column:0)+g[g.length-i.length].length-i[0].length:this.yylloc.first_column-u},this.options.ranges&&(this.yylloc.range=[b[0],b[0]+this.yyleng-u]),this.yyleng=this.yytext.length,this},"unput"),more:f(function(){return this._more=!0,this},"more"),reject:f(function(){if(this.options.backtrack_lexer)this._backtrack=!0;else return this.parseError("Lexical error on line "+(this.yylineno+1)+`. You can only invoke reject() in the lexer when the lexer is of the backtracking persuasion (options.backtrack_lexer = true).
`+this.showPosition(),{text:"",token:null,line:this.yylineno});return this},"reject"),less:f(function(a){this.unput(this.match.slice(a))},"less"),pastInput:f(function(){var a=this.matched.substr(0,this.matched.length-this.match.length);return(a.length>20?"...":"")+a.substr(-20).replace(/\n/g,"")},"pastInput"),upcomingInput:f(function(){var a=this.match;return a.length<20&&(a+=this._input.substr(0,20-a.length)),(a.substr(0,20)+(a.length>20?"...":"")).replace(/\n/g,"")},"upcomingInput"),showPosition:f(function(){var a=this.pastInput(),u=new Array(a.length+1).join("-");return a+this.upcomingInput()+`
`+u+"^"},"showPosition"),test_match:f(function(a,u){var i,g,b;if(this.options.backtrack_lexer&&(b={yylineno:this.yylineno,yylloc:{first_line:this.yylloc.first_line,last_line:this.last_line,first_column:this.yylloc.first_column,last_column:this.yylloc.last_column},yytext:this.yytext,match:this.match,matches:this.matches,matched:this.matched,yyleng:this.yyleng,offset:this.offset,_more:this._more,_input:this._input,yy:this.yy,conditionStack:this.conditionStack.slice(0),done:this.done},this.options.ranges&&(b.yylloc.range=this.yylloc.range.slice(0))),g=a[0].match(/(?:\r\n?|\n).*/g),g&&(this.yylineno+=g.length),this.yylloc={first_line:this.yylloc.last_line,last_line:this.yylineno+1,first_column:this.yylloc.last_column,last_column:g?g[g.length-1].length-g[g.length-1].match(/\r?\n?/)[0].length:this.yylloc.last_column+a[0].length},this.yytext+=a[0],this.match+=a[0],this.matches=a,this.yyleng=this.yytext.length,this.options.ranges&&(this.yylloc.range=[this.offset,this.offset+=this.yyleng]),this._more=!1,this._backtrack=!1,this._input=this._input.slice(a[0].length),this.matched+=a[0],i=this.performAction.call(this,this.yy,this,u,this.conditionStack[this.conditionStack.length-1]),this.done&&this._input&&(this.done=!1),i)return i;if(this._backtrack){for(var r in b)this[r]=b[r];return!1}return!1},"test_match"),next:f(function(){if(this.done)return this.EOF;this._input||(this.done=!0);var a,u,i,g;this._more||(this.yytext="",this.match="");for(var b=this._currentRules(),r=0;r<b.length;r++)if(i=this._input.match(this.rules[b[r]]),i&&(!u||i[0].length>u[0].length)){if(u=i,g=r,this.options.backtrack_lexer){if(a=this.test_match(i,b[r]),a!==!1)return a;if(this._backtrack){u=!1;continue}else return!1}else if(!this.options.flex)break}return u?(a=this.test_match(u,b[g]),a!==!1?a:!1):this._input===""?this.EOF:this.parseError("Lexical error on line "+(this.yylineno+1)+`. Unrecognized text.
`+this.showPosition(),{text:"",token:null,line:this.yylineno})},"next"),lex:f(function(){var u=this.next();return u||this.lex()},"lex"),begin:f(function(u){this.conditionStack.push(u)},"begin"),popState:f(function(){var u=this.conditionStack.length-1;return u>0?this.conditionStack.pop():this.conditionStack[0]},"popState"),_currentRules:f(function(){return this.conditionStack.length&&this.conditionStack[this.conditionStack.length-1]?this.conditions[this.conditionStack[this.conditionStack.length-1]].rules:this.conditions.INITIAL.rules},"_currentRules"),topState:f(function(u){return u=this.conditionStack.length-1-Math.abs(u||0),u>=0?this.conditionStack[u]:"INITIAL"},"topState"),pushState:f(function(u){this.begin(u)},"pushState"),stateStackSize:f(function(){return this.conditionStack.length},"stateStackSize"),options:{"case-insensitive":!0},performAction:f(function(u,i,g,b){function r(){let n=i.yytext.indexOf("%%");if(n===0)return!1;if(n>0){let B=i.yytext.slice(0,n),Y=i.yytext.slice(n);Y&&u.lexer.unput(Y),i.yytext=B}return!0}f(r,"processId");var K=b;switch(g){case 0:return 38;case 1:return 40;case 2:return 39;case 3:return 44;case 4:return 51;case 5:return 52;case 6:return 53;case 7:return 54;case 8:return 5;case 9:break;case 10:break;case 11:break;case 12:break;case 13:return this.pushState("SCALE"),17;break;case 14:return 18;case 15:this.popState();break;case 16:return this.begin("acc_title"),33;break;case 17:return this.popState(),"acc_title_value";break;case 18:return this.begin("acc_descr"),35;break;case 19:return this.popState(),"acc_descr_value";break;case 20:this.begin("acc_descr_multiline");break;case 21:this.popState();break;case 22:return"acc_descr_multiline_value";case 23:return this.pushState("CLASSDEF"),41;break;case 24:return this.popState(),this.pushState("CLASSDEFID"),"DEFAULT_CLASSDEF_ID";break;case 25:return this.popState(),this.pushState("CLASSDEFID"),42;break;case 26:return this.popState(),43;break;case 27:return this.pushState("CLASS"),48;break;case 28:return this.popState(),this.pushState("CLASS_STYLE"),49;break;case 29:return this.popState(),50;break;case 30:return this.pushState("STYLE"),45;break;case 31:return this.popState(),this.pushState("STYLEDEF_STYLES"),46;break;case 32:return this.popState(),47;break;case 33:return this.pushState("SCALE"),17;break;case 34:return 18;case 35:this.popState();break;case 36:this.pushState("STATE");break;case 37:return this.popState(),i.yytext=i.yytext.slice(0,-8).trim(),25;break;case 38:return this.popState(),i.yytext=i.yytext.slice(0,-8).trim(),26;break;case 39:return this.popState(),i.yytext=i.yytext.slice(0,-10).trim(),27;break;case 40:return this.popState(),i.yytext=i.yytext.slice(0,-8).trim(),25;break;case 41:return this.popState(),i.yytext=i.yytext.slice(0,-8).trim(),26;break;case 42:return this.popState(),i.yytext=i.yytext.slice(0,-10).trim(),27;break;case 43:return 51;case 44:return 52;case 45:return 53;case 46:return 54;case 47:this.pushState("STATE_STRING");break;case 48:return this.pushState("STATE_ID"),"AS";break;case 49:if(!r())return;return this.popState(),"ID";break;case 50:this.popState();break;case 51:return"STATE_DESCR";case 52:throw new Error('Error: State name must be a single word. Found: "'+i.yytext.trim()+'"');case 53:return 19;case 54:this.popState();break;case 55:return this.popState(),this.pushState("struct"),20;break;case 56:return this.popState(),21;break;case 57:break;case 58:return this.begin("NOTE"),29;break;case 59:return this.popState(),this.pushState("NOTE_ID"),59;break;case 60:return this.popState(),this.pushState("NOTE_ID"),60;break;case 61:this.popState(),this.pushState("FLOATING_NOTE");break;case 62:return this.popState(),this.pushState("FLOATING_NOTE_ID"),"AS";break;case 63:break;case 64:return"NOTE_TEXT";case 65:if(!r())return;return this.popState(),"ID";break;case 66:if(!r())return;return this.popState(),this.pushState("NOTE_TEXT"),24;break;case 67:return this.popState(),i.yytext=i.yytext.substr(2).trim(),31;break;case 68:return this.popState(),i.yytext=i.yytext.slice(0,-8).trim(),31;break;case 69:return 6;case 70:return 6;case 71:return 16;case 72:return 57;case 73:return r()?24:void 0;case 74:return i.yytext=i.yytext.trim(),14;break;case 75:return 15;case 76:return 28;case 77:return 58;case 78:return 5;case 79:return"INVALID"}},"anonymous"),rules:[/^(?:click\b)/i,/^(?:href\b)/i,/^(?:"[^"]*")/i,/^(?:default\b)/i,/^(?:.*direction\s+TB[^\n]*)/i,/^(?:.*direction\s+BT[^\n]*)/i,/^(?:.*direction\s+RL[^\n]*)/i,/^(?:.*direction\s+LR[^\n]*)/i,/^(?:[\n]+)/i,/^(?:[\s]+)/i,/^(?:((?!\n)\s)+)/i,/^(?:#[^\n]*)/i,/^(?:%%(?!\{)[^\n]*)/i,/^(?:scale\s+)/i,/^(?:\d+)/i,/^(?:\s+width\b)/i,/^(?:accTitle\s*:\s*)/i,/^(?:(?!\n||)*[^\n]*)/i,/^(?:accDescr\s*:\s*)/i,/^(?:(?!\n||)*[^\n]*)/i,/^(?:accDescr\s*\{\s*)/i,/^(?:[\}])/i,/^(?:[^\}]*)/i,/^(?:classDef\s+)/i,/^(?:DEFAULT\s+)/i,/^(?:\w+\s+)/i,/^(?:[^\n]*)/i,/^(?:class\s+)/i,/^(?:(\w+)+((,\s*\w+)*))/i,/^(?:[^\n]*)/i,/^(?:style\s+)/i,/^(?:[\w,]+\s+)/i,/^(?:[^\n]*)/i,/^(?:scale\s+)/i,/^(?:\d+)/i,/^(?:\s+width\b)/i,/^(?:state\s+)/i,/^(?:.*<<fork>>)/i,/^(?:.*<<join>>)/i,/^(?:.*<<choice>>)/i,/^(?:.*\[\[fork\]\])/i,/^(?:.*\[\[join\]\])/i,/^(?:.*\[\[choice\]\])/i,/^(?:.*direction\s+TB[^\n]*)/i,/^(?:.*direction\s+BT[^\n]*)/i,/^(?:.*direction\s+RL[^\n]*)/i,/^(?:.*direction\s+LR[^\n]*)/i,/^(?:["])/i,/^(?:\s*as\s+)/i,/^(?:[^\n\{]*)/i,/^(?:["])/i,/^(?:[^"]*)/i,/^(?:\w+\s+\w+.*?\{)/i,/^(?:[^\n\s\{]+)/i,/^(?:\n)/i,/^(?:\{)/i,/^(?:\})/i,/^(?:[\n])/i,/^(?:note\s+)/i,/^(?:left of\b)/i,/^(?:right of\b)/i,/^(?:")/i,/^(?:\s*as\s*)/i,/^(?:["])/i,/^(?:[^"]*)/i,/^(?:[^\n]*)/i,/^(?:\s*[^:\n\s\-]+)/i,/^(?:\s*:[^:\n;]+)/i,/^(?:[\s\S]*?\n\s*end note\b)/i,/^(?:stateDiagram\s+)/i,/^(?:stateDiagram-v2\s+)/i,/^(?:hide empty description\b)/i,/^(?:\[\*\])/i,/^(?:[^:\n\s\-\{]+)/i,/^(?:\s*:(?:[^:\n;]|:[^:\n;])+)/i,/^(?:-->)/i,/^(?:--)/i,/^(?::::)/i,/^(?:$)/i,/^(?:.)/i],conditions:{LINE:{rules:[10,11,12],inclusive:!1},struct:{rules:[10,11,12,23,27,30,36,43,44,45,46,56,57,58,72,73,74,75,76,77],inclusive:!1},FLOATING_NOTE_ID:{rules:[65],inclusive:!1},FLOATING_NOTE:{rules:[62,63,64],inclusive:!1},NOTE_TEXT:{rules:[67,68],inclusive:!1},NOTE_ID:{rules:[66],inclusive:!1},NOTE:{rules:[59,60,61],inclusive:!1},STYLEDEF_STYLEOPTS:{rules:[],inclusive:!1},STYLEDEF_STYLES:{rules:[32],inclusive:!1},STYLE_IDS:{rules:[],inclusive:!1},STYLE:{rules:[31],inclusive:!1},CLASS_STYLE:{rules:[29],inclusive:!1},CLASS:{rules:[28],inclusive:!1},CLASSDEFID:{rules:[26],inclusive:!1},CLASSDEF:{rules:[24,25],inclusive:!1},acc_descr_multiline:{rules:[21,22],inclusive:!1},acc_descr:{rules:[19],inclusive:!1},acc_title:{rules:[17],inclusive:!1},SCALE:{rules:[14,15,34,35],inclusive:!1},ALIAS:{rules:[],inclusive:!1},STATE_ID:{rules:[49],inclusive:!1},STATE_STRING:{rules:[50,51],inclusive:!1},FORK_STATE:{rules:[],inclusive:!1},STATE:{rules:[10,11,12,37,38,39,40,41,42,47,48,52,53,54,55],inclusive:!1},ID:{rules:[10,11,12],inclusive:!1},INITIAL:{rules:[0,1,2,3,4,5,6,7,8,9,11,12,13,16,18,20,23,27,30,33,36,55,58,69,70,71,72,73,74,75,77,78,79],inclusive:!0}}};return V})();Tt.lexer=de;function ct(){this.yy={}}return f(ct,"Parser"),ct.prototype=Tt,Tt.Parser=ct,new ct})();Ct.parser=Ct;var Je=Ct,ye="TB",Zt="TB",Ht="dir",q="state",J="root",At="relation",ge="classDef",Te="style",be="applyClass",et="default",te="divider",ee="fill:none",se="fill: #333",re="c",ie="markdown",ae="normal",Dt="rect",vt="rectWithTitle",Ee="stateStart",me="stateEnd",zt="divider",Kt="roundedWithTitle",ke="note",_e="noteGroup",st="statediagram",De="state",ve=`${st}-${De}`,ne="transition",Ce="note",Ae="note-edge",xe=`${ne} ${Ae}`,Le=`${st}-${Ce}`,Ie="cluster",we=`${st}-${Ie}`,Oe="cluster-alt",Ne=`${st}-${Oe}`,oe="parent",le="note",Re="state",xt="----",$e=`${xt}${le}`,Xt=`${xt}${oe}`,ce=f((t,e=Zt)=>{if(!t.doc)return e;let l=e;for(let s of t.doc)s.stmt==="dir"&&(l=s.value);return l},"getDir"),Fe=f(function(t,e){return e.db.getClasses()},"getClasses"),Pe=f(async function(t,e,l,s){E.info("REF0:"),E.info("Drawing state diagram (v2)",e);let{securityLevel:c,state:h,layout:p}=R();s.db.extract(s.db.getRootDocV2());let y=s.db.getData(),o=Wt(e,c);y.type=s.type,y.layoutAlgorithm=p,y.nodeSpacing=h?.nodeSpacing||50,y.rankSpacing=h?.rankSpacing||50,R().look==="neo"?y.markers=["barbNeo"]:y.markers=["barb"],y.diagramId=e,await Mt(y,o);let m=8;try{(typeof s.db.getLinks=="function"?s.db.getLinks():new Map).forEach((x,_)=>{let d=typeof _=="string"?_:typeof _?.id=="string"?_.id:"",L=y.nodes.find(I=>I.id===d);if(!d){E.warn("\u26A0\uFE0F Invalid or missing stateId from key:",JSON.stringify(_));return}let $=o.node()?.querySelectorAll("g.node, g.rough-node"),C;if($?.forEach(I=>{let H=I.textContent?.trim();(I.id===L?.domId||H===d)&&(C=I)}),!C){E.warn("\u26A0\uFE0F Could not find node matching text:",d);return}let F=C.parentNode;if(!F){E.warn("\u26A0\uFE0F Node has no parent, cannot wrap:",d);return}let A=document.createElementNS("http://www.w3.org/2000/svg","a"),P=x.url.replace(/^"+|"+$/g,"");if(A.setAttributeNS("http://www.w3.org/1999/xlink","xlink:href",P),A.setAttribute("target","_blank"),x.tooltip){let I=x.tooltip.replace(/^"+|"+$/g,"");A.setAttribute("title",I),C.setAttribute("title",I)}F.replaceChild(A,C),A.appendChild(C),E.info("\u{1F517} Wrapped node in <a> tag for:",d,x.url)})}catch(O){E.error("\u274C Error injecting clickable links:",O)}Vt.insertTitle(o,"statediagramTitleText",h?.titleTopMargin??25,s.db.getDiagramTitle()),jt(o,m,st,h?.useMaxWidth??!0)},"draw"),qe={getClasses:Fe,draw:Pe,getDir:ce},yt=new Map,U=0;function gt(t="",e=0,l="",s=xt){let c=l!==null&&l.length>0?`${s}${l}`:"";return`${Re}-${t}${c}-${e}`}f(gt,"stateDomId");var Be=f((t,e,l,s,c,h,p,y)=>{E.trace("items",e),e.forEach(o=>{switch(o.stmt){case q:tt(t,o,l,s,c,h,p,y);break;case et:tt(t,o,l,s,c,h,p,y);break;case At:{tt(t,o.state1,l,s,c,h,p,y),tt(t,o.state2,l,s,c,h,p,y);let T=p==="neo",m={id:"edge"+U,start:o.state1.id,end:o.state2.id,arrowhead:"normal",arrowTypeEnd:T?"arrow_barb_neo":"arrow_barb",style:ee,labelStyle:"",label:M.sanitizeText(o.description??"",R()),arrowheadStyle:se,labelpos:re,labelType:ie,thickness:ae,classes:ne,look:p};c.push(m),U++}break}})},"setupDoc"),Jt=f((t,e=Zt)=>{let l=e;if(t.doc)for(let s of t.doc)s.stmt==="dir"&&(l=s.value);return l},"getDir");function Z(t,e,l){if(!e.id||e.id==="</join></fork>"||e.id==="</choice>")return;e.cssClasses&&(Array.isArray(e.cssCompiledStyles)||(e.cssCompiledStyles=[]),e.cssClasses.split(" ").forEach(c=>{let h=l.get(c);h&&(e.cssCompiledStyles=[...e.cssCompiledStyles??[],...h.styles])}));let s=t.find(c=>c.id===e.id);s?Object.assign(s,e):t.push(e)}f(Z,"insertOrUpdateNode");function he(t){return t?.classes?.join(" ")??""}f(he,"getClassesFromDbInfo");function ue(t){return t?.styles??[]}f(ue,"getStylesFromDbInfo");var tt=f((t,e,l,s,c,h,p,y)=>{let o=e.id,T=l.get(o),m=he(T),O=ue(T),x=R();if(E.info("dataFetcher parsedItem",e,T,O),o!=="root"){let _=Dt;e.start===!0?_=Ee:e.start===!1&&(_=me),e.type!==et&&(_=e.type),yt.get(o)||yt.set(o,{id:o,shape:_,description:M.sanitizeText(o,x),cssClasses:`${m} ${ve}`,cssStyles:O});let d=yt.get(o);e.description&&(Array.isArray(d.description)?(d.shape=vt,d.description.push(e.description)):d.description?.length&&d.description.length>0?(d.shape=vt,d.description===o?d.description=[e.description]:d.description=[d.description,e.description]):(d.shape=Dt,d.description=e.description),d.description=M.sanitizeTextOrArray(d.description,x)),d.description?.length===1&&d.shape===vt&&(d.type==="group"?d.shape=Kt:d.shape=Dt),!d.type&&e.doc&&(E.info("Setting cluster for XCX",o,Jt(e)),d.type="group",d.isGroup=!0,d.dir=Jt(e),d.shape=e.type===te?zt:Kt,d.cssClasses=`${d.cssClasses} ${we} ${h?Ne:""}`);let L={labelStyle:"",shape:d.shape,label:d.description,cssClasses:d.cssClasses,cssCompiledStyles:[],cssStyles:d.cssStyles,id:o,dir:d.dir,domId:gt(o,U),type:d.type,isGroup:d.type==="group",padding:8,rx:10,ry:10,look:p,labelType:"markdown"};if(L.shape===zt&&(L.label=""),t&&t.id!=="root"&&(E.trace("Setting node ",o," to be child of its parent ",t.id),L.parentId=t.id),L.centerLabel=!0,e.note){let $={labelStyle:"",shape:ke,label:e.note.text,labelType:"markdown",cssClasses:Le,cssStyles:[],cssCompiledStyles:[],id:o+$e+"-"+U,domId:gt(o,U,le),type:d.type,isGroup:d.type==="group",padding:x.flowchart?.padding,look:p,position:e.note.position},C=o+Xt,F={labelStyle:"",shape:_e,label:e.note.text,cssClasses:d.cssClasses,cssStyles:[],id:o+Xt,domId:gt(o,U,oe),type:"group",isGroup:!0,padding:16,look:p,position:e.note.position};U++,F.id=C,$.parentId=C,Z(s,F,y),Z(s,$,y),Z(s,L,y);let A=o,P=$.id;e.note.position==="left of"&&(A=$.id,P=o),c.push({id:A+"-"+P,start:A,end:P,arrowhead:"none",arrowTypeEnd:"",style:ee,labelStyle:"",classes:xe,arrowheadStyle:se,labelpos:re,labelType:ie,thickness:ae,look:p})}else Z(s,L,y)}e.doc&&(E.trace("Adding nodes children "),Be(e,e.doc,l,s,c,!h,p,y))},"dataFetcher"),Ye=f(()=>{yt.clear(),U=0},"reset"),v={START_NODE:"[*]",START_TYPE:"start",END_NODE:"[*]",END_TYPE:"end",COLOR_KEYWORD:"color",FILL_KEYWORD:"fill",BG_FILL:"bgFill",STYLECLASS_SEP:","},qt=f(()=>new Map,"newClassesList"),Qt=f(()=>({relations:[],states:new Map,documents:{}}),"newDoc"),St=f(t=>JSON.parse(JSON.stringify(t)),"clone"),ts=class{constructor(t){this.version=t,this.nodes=[],this.edges=[],this.rootDoc=[],this.classes=qt(),this.documents={root:Qt()},this.currentDocument=this.documents.root,this.startEndCount=0,this.dividerCnt=0,this.links=new Map,this.funs=[],this.getAccTitle=$t,this.setAccTitle=Rt,this.getAccDescription=Pt,this.setAccDescription=Ft,this.setDiagramTitle=Bt,this.getDiagramTitle=Yt,this.clear(),this.setRootDoc=this.setRootDoc.bind(this),this.getDividerId=this.getDividerId.bind(this),this.setDirection=this.setDirection.bind(this),this.trimColon=this.trimColon.bind(this),this.bindFunctions=this.bindFunctions.bind(this)}static{f(this,"StateDB")}static{this.relationType={AGGREGATION:0,EXTENSION:1,COMPOSITION:2,DEPENDENCY:3}}extract(t){this.clear(!0);for(let s of Array.isArray(t)?t:t.doc)switch(s.stmt){case q:this.addState(s.id.trim(),s.type,s.doc,s.description,s.note);break;case At:this.addRelation(s.state1,s.state2,s.description);break;case ge:this.addStyleClass(s.id.trim(),s.classes);break;case Te:this.handleStyleDef(s);break;case be:this.setCssClass(s.id.trim(),s.styleClass);break;case"click":this.addLink(s.id,s.url,s.tooltip);break}let e=this.getStates(),l=R();Ye(),tt(void 0,this.getRootDocV2(),e,this.nodes,this.edges,!0,l.look,this.classes);for(let s of this.nodes)if(Array.isArray(s.label)){if(s.description=s.label.slice(1),s.isGroup&&s.description.length>0)throw new Error(`Group nodes can only have label. Remove the additional description for node [${s.id}]`);s.label=s.label[0]}}handleStyleDef(t){let e=t.id.trim().split(","),l=t.styleClass.split(",");for(let s of e){let c=this.getState(s);if(!c){let h=s.trim();this.addState(h),c=this.getState(h)}c&&(c.styles=l.map(h=>h.replace(/;/g,"")?.trim()))}}setRootDoc(t){E.info("Setting root doc",t),this.rootDoc=t,this.version===1?this.extract(t):this.extract(this.getRootDocV2())}docTranslator(t,e,l){if(e.stmt===At){this.docTranslator(t,e.state1,!0),this.docTranslator(t,e.state2,!1);return}if(e.stmt===q&&(e.id===v.START_NODE?(e.id=t.id+(l?"_start":"_end"),e.start=l):e.id=e.id.trim()),e.stmt!==J&&e.stmt!==q||!e.doc)return;let s=[],c=[];for(let h of e.doc)if(h.type===te){let p=St(h);p.doc=St(c),s.push(p),c=[]}else c.push(h);if(s.length>0&&c.length>0){let h={stmt:q,id:Gt(),type:"divider",doc:St(c)};s.push(St(h)),e.doc=s}e.doc.forEach(h=>this.docTranslator(e,h,!0))}getRootDocV2(){return this.docTranslator({id:J,stmt:J},{id:J,stmt:J,doc:this.rootDoc},!0),{id:J,doc:this.rootDoc}}addState(t,e=et,l=void 0,s=void 0,c=void 0,h=void 0,p=void 0,y=void 0){let o=t?.trim();if(!this.currentDocument.states.has(o))E.info("Adding state ",o,s),this.currentDocument.states.set(o,{stmt:q,id:o,descriptions:[],type:e,doc:l,note:c,classes:[],styles:[],textStyles:[]});else{let T=this.currentDocument.states.get(o);if(!T)throw new Error(`State not found: ${o}`);T.doc||(T.doc=l),T.type||(T.type=e)}if(s&&(E.info("Setting state description",o,s),(Array.isArray(s)?s:[s]).forEach(m=>this.addDescription(o,m.trim()))),c){let T=this.currentDocument.states.get(o);if(!T)throw new Error(`State not found: ${o}`);T.note=c,T.note.text=M.sanitizeText(T.note.text,R())}h&&(E.info("Setting state classes",o,h),(Array.isArray(h)?h:[h]).forEach(m=>this.setCssClass(o,m.trim()))),p&&(E.info("Setting state styles",o,p),(Array.isArray(p)?p:[p]).forEach(m=>this.setStyle(o,m.trim()))),y&&(E.info("Setting state styles",o,p),(Array.isArray(y)?y:[y]).forEach(m=>this.setTextStyle(o,m.trim())))}clear(t){this.nodes=[],this.edges=[],this.funs=[this.setupToolTips.bind(this)],this.documents={root:Qt()},this.currentDocument=this.documents.root,this.startEndCount=0,this.classes=qt(),t||(this.links=new Map,Nt())}getState(t){return this.currentDocument.states.get(t)}getStates(){return this.currentDocument.states}logDocuments(){E.info("Documents = ",this.documents)}getRelations(){return this.currentDocument.relations}addLink(t,e,l){this.links.set(t,{url:e,tooltip:l}),E.warn("Adding link",t,e,l)}getLinks(){return this.links}startIdIfNeeded(t=""){return t===v.START_NODE?(this.startEndCount++,`${v.START_TYPE}${this.startEndCount}`):t}startTypeIfNeeded(t="",e=et){return t===v.START_NODE?v.START_TYPE:e}endIdIfNeeded(t=""){return t===v.END_NODE?(this.startEndCount++,`${v.END_TYPE}${this.startEndCount}`):t}endTypeIfNeeded(t="",e=et){return t===v.END_NODE?v.END_TYPE:e}addRelationObjs(t,e,l=""){let s=this.startIdIfNeeded(t.id.trim()),c=this.startTypeIfNeeded(t.id.trim(),t.type),h=this.startIdIfNeeded(e.id.trim()),p=this.startTypeIfNeeded(e.id.trim(),e.type);this.addState(s,c,t.doc,t.description,t.note,t.classes,t.styles,t.textStyles),this.addState(h,p,e.doc,e.description,e.note,e.classes,e.styles,e.textStyles),this.currentDocument.relations.push({id1:s,id2:h,relationTitle:M.sanitizeText(l,R())})}addRelation(t,e,l){if(typeof t=="object"&&typeof e=="object")this.addRelationObjs(t,e,l);else if(typeof t=="string"&&typeof e=="string"){let s=this.startIdIfNeeded(t.trim()),c=this.startTypeIfNeeded(t),h=this.endIdIfNeeded(e.trim()),p=this.endTypeIfNeeded(e);this.addState(s,c),this.addState(h,p),this.currentDocument.relations.push({id1:s,id2:h,relationTitle:l?M.sanitizeText(l,R()):void 0})}}addDescription(t,e){let l=this.currentDocument.states.get(t),s=e.startsWith(":")?e.replace(":","").trim():e;l?.descriptions?.push(M.sanitizeText(s,R()))}cleanupLabel(t){return t.startsWith(":")?t.slice(2).trim():t.trim()}getDividerId(){return this.dividerCnt++,`divider-id-${this.dividerCnt}`}addStyleClass(t,e=""){this.classes.has(t)||this.classes.set(t,{id:t,styles:[],textStyles:[]});let l=this.classes.get(t);e&&l&&e.split(v.STYLECLASS_SEP).forEach(s=>{let c=s.replace(/([^;]*);/,"$1").trim();if(RegExp(v.COLOR_KEYWORD).exec(s)){let p=c.replace(v.FILL_KEYWORD,v.BG_FILL).replace(v.COLOR_KEYWORD,v.FILL_KEYWORD);l.textStyles.push(p)}l.styles.push(c)})}getClasses(){return this.classes}setupToolTips(t){let e=Ut();pt(t).select("svg").selectAll("g.node, g.rough-node").on("mouseover",c=>{let h=pt(c.currentTarget),p=h.attr("title");if(p===null)return;let y=c.currentTarget?.getBoundingClientRect();e.transition().duration(200).style("opacity",".9"),e.style("left",window.scrollX+y.left+(y.right-y.left)/2+"px").style("top",window.scrollY+y.bottom+"px"),e.html(Ot.sanitize(p)),h.classed("hover",!0)}).on("mouseout",c=>{e.transition().duration(500).style("opacity",0),pt(c.currentTarget).classed("hover",!1)})}setCssClass(t,e){t.split(",").forEach(l=>{let s=this.getState(l);if(!s){let c=l.trim();this.addState(c),s=this.getState(c)}s?.classes?.push(e)})}setStyle(t,e){this.getState(t)?.styles?.push(e)}setTextStyle(t,e){this.getState(t)?.textStyles?.push(e)}bindFunctions(t){this.funs.forEach(e=>{e(t)})}getDirectionStatement(){return this.rootDoc.find(t=>t.stmt===Ht)}getDirection(){return this.getDirectionStatement()?.value??ye}setDirection(t){let e=this.getDirectionStatement();e?e.value=t:this.rootDoc.unshift({stmt:Ht,value:t})}trimColon(t){return t.startsWith(":")?t.slice(1).trim():t.trim()}getData(){let t=R();return{nodes:this.nodes,edges:this.edges,other:{},config:t,direction:ce(this.getRootDocV2())}}getConfig(){return R().state}},Ge=f(t=>`
defs [id$="-barbEnd"] {
    fill: ${t.transitionColor};
    stroke: ${t.transitionColor};
  }
g.stateGroup text {
  fill: ${t.nodeBorder};
  stroke: none;
  font-size: 10px;
}
g.stateGroup text {
  fill: ${t.textColor};
  stroke: none;
  font-size: 10px;

}
g.stateGroup .state-title {
  font-weight: bolder;
  fill: ${t.stateLabelColor};
}

g.stateGroup rect {
  fill: ${t.mainBkg};
  stroke: ${t.nodeBorder};
}

g.stateGroup line {
  stroke: ${t.lineColor};
  stroke-width: ${t.strokeWidth||1};
}

.transition {
  stroke: ${t.transitionColor};
  stroke-width: ${t.strokeWidth||1};
  fill: none;
}

.stateGroup .composit {
  fill: ${t.background};
  border-bottom: 1px
}

.stateGroup .alt-composit {
  fill: #e0e0e0;
  border-bottom: 1px
}

.state-note {
  stroke: ${t.noteBorderColor};
  fill: ${t.noteBkgColor};

  text {
    fill: ${t.noteTextColor};
    stroke: none;
    font-size: 10px;
  }
}

.stateLabel .box {
  stroke: none;
  stroke-width: 0;
  fill: ${t.mainBkg};
  opacity: 0.5;
}

.edgeLabel .label rect {
  fill: ${t.labelBackgroundColor};
  opacity: 0.5;
}
.edgeLabel {
  background-color: ${t.edgeLabelBackground};
  p {
    background-color: ${t.edgeLabelBackground};
  }
  rect {
    opacity: 0.5;
    background-color: ${t.edgeLabelBackground};
    fill: ${t.edgeLabelBackground};
  }
  text-align: center;
}
.edgeLabel .label text {
  fill: ${t.transitionLabelColor||t.tertiaryTextColor};
}
.label div .edgeLabel {
  color: ${t.transitionLabelColor||t.tertiaryTextColor};
}

.stateLabel text {
  fill: ${t.stateLabelColor};
  font-size: 10px;
  font-weight: bold;
}

.node circle.state-start {
  fill: ${t.specialStateColor};
  stroke: ${t.specialStateColor};
}

.node .fork-join {
  fill: ${t.specialStateColor};
  stroke: ${t.specialStateColor};
}

.node circle.state-end {
  fill: ${t.innerEndBackground};
  stroke: ${t.background};
  stroke-width: 1.5
}
.end-state-inner {
  fill: ${t.compositeBackground||t.background};
  // stroke: ${t.background};
  stroke-width: 1.5
}

.node rect {
  fill: ${t.stateBkg||t.mainBkg};
  stroke: ${t.stateBorder||t.nodeBorder};
  stroke-width: ${t.strokeWidth||1}px;
}
.node polygon {
  fill: ${t.mainBkg};
  stroke: ${t.stateBorder||t.nodeBorder};;
  stroke-width: ${t.strokeWidth||1}px;
}
[id$="-barbEnd"] {
  fill: ${t.lineColor};
}

.statediagram-cluster rect {
  fill: ${t.compositeTitleBackground};
  stroke: ${t.stateBorder||t.nodeBorder};
  stroke-width: ${t.strokeWidth||1}px;
}

.cluster-label, .nodeLabel {
  color: ${t.stateLabelColor};
  // line-height: 1;
}

.statediagram-cluster rect.outer {
  rx: 5px;
  ry: 5px;
}
.statediagram-state .divider {
  stroke: ${t.stateBorder||t.nodeBorder};
}

.statediagram-state .title-state {
  rx: 5px;
  ry: 5px;
}
.statediagram-cluster.statediagram-cluster .inner {
  fill: ${t.compositeBackground||t.background};
}
.statediagram-cluster.statediagram-cluster-alt .inner {
  fill: ${t.altBackground?t.altBackground:"#efefef"};
}

.statediagram-cluster .inner {
  rx:0;
  ry:0;
}

.statediagram-state rect.basic {
  rx: 5px;
  ry: 5px;
}
.statediagram-state rect.divider {
  stroke-dasharray: 10,10;
  fill: ${t.altBackground?t.altBackground:"#efefef"};
}

.note-edge {
  stroke-dasharray: 5;
}

.statediagram-note rect {
  fill: ${t.noteBkgColor};
  stroke: ${t.noteBorderColor};
  stroke-width: 1px;
  rx: 0;
  ry: 0;
}
.statediagram-note rect {
  fill: ${t.noteBkgColor};
  stroke: ${t.noteBorderColor};
  stroke-width: 1px;
  rx: 0;
  ry: 0;
}

.statediagram-note text {
  fill: ${t.noteTextColor};
}

.statediagram-note .nodeLabel {
  color: ${t.noteTextColor};
}
.statediagram .edgeLabel {
  color: red; // ${t.noteTextColor};
}

[id$="-dependencyStart"], [id$="-dependencyEnd"] {
  fill: ${t.lineColor};
  stroke: ${t.lineColor};
  stroke-width: ${t.strokeWidth||1};
}

.statediagramTitleText {
  text-anchor: middle;
  font-size: 18px;
  fill: ${t.textColor};
}

[data-look="neo"].statediagram-cluster rect {
  fill: ${t.mainBkg};
  stroke: ${t.useGradient?"url("+t.svgId+"-gradient)":t.stateBorder||t.nodeBorder};
  stroke-width: ${t.strokeWidth??1};
}
[data-look="neo"].statediagram-cluster rect.outer {
  rx: ${t.radius}px;
  ry: ${t.radius}px;
  filter: ${t.dropShadow?t.dropShadow.replace("url(#drop-shadow)",`url(${t.svgId}-drop-shadow)`):"none"}
}
`,"getStyles"),es=Ge;export{Je as a,qe as b,ts as c,es as d};
