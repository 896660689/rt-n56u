<!DOCTYPE html>
<html lang="zh-cmn-hans">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>SSR_URL解析</title>
    <style>
      /*Original highlight.js style (c) Ivan Sagalaev <maniac@softwaremaniacs.org>*/
      .hljs{display:block;overflow-x:auto;padding:0.5em;background:#F0F0F0;}.hljs,.hljs-subst{color:#444;}.hljs-comment{color:#888888;}.hljs-keyword,.hljs-attribute,.hljs-selector-tag,.hljs-meta-keyword,.hljs-doctag,.hljs-name{font-weight:bold;}.hljs-type,.hljs-string,.hljs-number,.hljs-selector-id,.hljs-selector-class,.hljs-quote,.hljs-template-tag,.hljs-deletion{color:#880000;}.hljs-title,.hljs-section{color:#880000;font-weight:bold;}.hljs-regexp,.hljs-symbol,.hljs-variable,.hljs-template-variable,.hljs-link,.hljs-selector-attr,.hljs-selector-pseudo{color:#BC6060;}.hljs-literal{color:#78A960;}.hljs-built_in,.hljs-bullet,.hljs-code,.hljs-addition{color:#397300;}.hljs-meta{color:#1f7199;}.hljs-meta-string{color:#4d99bf;}.hljs-emphasis{font-style:italic;}.hljs-strong{font-weight:bold;}
      
      html {font-family: Consolas, 'PingFang SC', 'Microsoft YaHei', sans-serif}
      body {margin: 0; padding: 0}
      li {list-style-type: none}
      textarea, input {outline: none}
      .hljs {
        font-family: 'Monaco', sans-serif;
      }
      .button {
        cursor: pointer;
        border-bottom: solid 1px transparent;
        transition: border .4s ease
      }
      .button:hover {border-bottom-color: black}
      .input {line-height: 30px}
      .wrap {
        width: 360px;
        position: relative;
        margin: auto;
        border: solid #ccc 1px;
        min-height: 700px
      }
      #workspace .line {
        margin-top: 10px;
        padding: 0 16px
      }
      #results {padding: 10px}
      #draws {
        width: 100%;
        position: absolute;
        margin: 0 auto;
        top: 0;
      }
      .input-multi {
        width: 100%;
        height: 40px;
        box-sizing: border-box;
        padding: 10px;
        transition: all .3s ease;
        resize: vertical;
        font-size: 16px;
        font-weight: 200;
      }
      .input-multi:focus { height: 300px }
      .server-config { margin-bottom: 20px }
      .server-config > li {
        display: block;
        height: 30px;
        line-height: 30px;
        border-bottom: dashed 1px #ccc;
      }
      .server-config > li:last-of-type { border-bottom: 0 }
      .server-config > li span { padding: 0 5px }
      .server-config > li span:first-child {
        width: 80px;
        display: inline-block;
        border-right: dashed 1px #ccc;
        color: #aaa;
        text-align: right
      }
    </style>
  </head>
  <body>
    <div class="wrap">
      <div id="workspace">
        <div id="data-input">
          <div class="line">
            <textarea type="text" 
             placeholder="粘贴SSR链接(ssr://xxx)或订阅地址" 
             class="input input-multi" id="data-source"></textarea>
            </div>
          <div class="line">
            <a class="button" id="clear">清空</a>
          </div>
          <div class="line">
            <a class="button" id="save2jsonfile">保存为json文件</a>
            <a class="button" id="preview-result">预览配置文件</a>
          </div>
        </div>
        <div id="results"></div>
        <div id="draws"></div>
      </div>
    </div>
    <script>
      (function () {
        String.prototype.replaceAll = function (searchVal, replaceVal) {
            var ret = this
            while (ret.includes(searchVal)) {
                ret = ret.replace(searchVal, replaceVal)
            }
            return ret
        }
        /*! highlight.js v9.15.6 | BSD3 License | git.io/hljslicense */
        !function(e){var n="object"==typeof window&&window||"object"==typeof self&&self;"undefined"!=typeof exports?e(exports):n&&(n.hljs=e({}),"function"==typeof define&&define.amd&&define([],function(){return n.hljs}))}(function(a){var E=[],u=Object.keys,N={},g={},n=/^(no-?highlight|plain|text)$/i,R=/\blang(?:uage)?-([\w-]+)\b/i,t=/((^(<[^>]+>|\t|)+|(?:\n)))/gm,r={case_insensitive:"cI",lexemes:"l",contains:"c",keywords:"k",subLanguage:"sL",className:"cN",begin:"b",beginKeywords:"bK",end:"e",endsWithParent:"eW",illegal:"i",excludeBegin:"eB",excludeEnd:"eE",returnBegin:"rB",returnEnd:"rE",relevance:"r",variants:"v",IDENT_RE:"IR",UNDERSCORE_IDENT_RE:"UIR",NUMBER_RE:"NR",C_NUMBER_RE:"CNR",BINARY_NUMBER_RE:"BNR",RE_STARTERS_RE:"RSR",BACKSLASH_ESCAPE:"BE",APOS_STRING_MODE:"ASM",QUOTE_STRING_MODE:"QSM",PHRASAL_WORDS_MODE:"PWM",C_LINE_COMMENT_MODE:"CLCM",C_BLOCK_COMMENT_MODE:"CBCM",HASH_COMMENT_MODE:"HCM",NUMBER_MODE:"NM",C_NUMBER_MODE:"CNM",BINARY_NUMBER_MODE:"BNM",CSS_NUMBER_MODE:"CSSNM",REGEXP_MODE:"RM",TITLE_MODE:"TM",UNDERSCORE_TITLE_MODE:"UTM",COMMENT:"C",beginRe:"bR",endRe:"eR",illegalRe:"iR",lexemesRe:"lR",terminators:"t",terminator_end:"tE"},b="</span>",h={classPrefix:"hljs-",tabReplace:null,useBR:!1,languages:void 0};function _(e){return e.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;")}function d(e){return e.nodeName.toLowerCase()}function v(e,n){var t=e&&e.exec(n);return t&&0===t.index}function p(e){return n.test(e)}function l(e){var n,t={},r=Array.prototype.slice.call(arguments,1);for(n in e)t[n]=e[n];return r.forEach(function(e){for(n in e)t[n]=e[n]}),t}function M(e){var a=[];return function e(n,t){for(var r=n.firstChild;r;r=r.nextSibling)3===r.nodeType?t+=r.nodeValue.length:1===r.nodeType&&(a.push({event:"start",offset:t,node:r}),t=e(r,t),d(r).match(/br|hr|img|input/)||a.push({event:"stop",offset:t,node:r}));return t}(e,0),a}function i(e){if(r&&!e.langApiRestored){for(var n in e.langApiRestored=!0,r)e[n]&&(e[r[n]]=e[n]);(e.c||[]).concat(e.v||[]).forEach(i)}}function m(c){function s(e){return e&&e.source||e}function o(e,n){return new RegExp(s(e),"m"+(c.cI?"i":"")+(n?"g":""))}!function n(t,e){if(!t.compiled){if(t.compiled=!0,t.k=t.k||t.bK,t.k){var r={},a=function(t,e){c.cI&&(e=e.toLowerCase()),e.split(" ").forEach(function(e){var n=e.split("|");r[n[0]]=[t,n[1]?Number(n[1]):1]})};"string"==typeof t.k?a("keyword",t.k):u(t.k).forEach(function(e){a(e,t.k[e])}),t.k=r}t.lR=o(t.l||/\w+/,!0),e&&(t.bK&&(t.b="\\b("+t.bK.split(" ").join("|")+")\\b"),t.b||(t.b=/\B|\b/),t.bR=o(t.b),t.endSameAsBegin&&(t.e=t.b),t.e||t.eW||(t.e=/\B|\b/),t.e&&(t.eR=o(t.e)),t.tE=s(t.e)||"",t.eW&&e.tE&&(t.tE+=(t.e?"|":"")+e.tE)),t.i&&(t.iR=o(t.i)),null==t.r&&(t.r=1),t.c||(t.c=[]),t.c=Array.prototype.concat.apply([],t.c.map(function(e){return(n="self"===e?t:e).v&&!n.cached_variants&&(n.cached_variants=n.v.map(function(e){return l(n,{v:null},e)})),n.cached_variants||n.eW&&[l(n)]||[n];var n})),t.c.forEach(function(e){n(e,t)}),t.starts&&n(t.starts,e);var i=t.c.map(function(e){return e.bK?"\\.?(?:"+e.b+")\\.?":e.b}).concat([t.tE,t.i]).map(s).filter(Boolean);t.t=i.length?o(function(e,n){for(var t=/\[(?:[^\\\]]|\\.)*\]|\(\??|\\([1-9][0-9]*)|\\./,r=0,a="",i=0;i<e.length;i++){var c=r,o=s(e[i]);for(0<i&&(a+=n);0<o.length;){var u=t.exec(o);if(null==u){a+=o;break}a+=o.substring(0,u.index),o=o.substring(u.index+u[0].length),"\\"==u[0][0]&&u[1]?a+="\\"+String(Number(u[1])+c):(a+=u[0],"("==u[0]&&r++)}}return a}(i,"|"),!0):{exec:function(){return null}}}}(c)}function C(e,n,o,t){function u(e,n,t,r){var a='<span class="'+(r?"":h.classPrefix);return(a+=e+'">')+n+(t?"":b)}function s(){g+=null!=E.sL?function(){var e="string"==typeof E.sL;if(e&&!N[E.sL])return _(R);var n=e?C(E.sL,R,!0,i[E.sL]):O(R,E.sL.length?E.sL:void 0);return 0<E.r&&(d+=n.r),e&&(i[E.sL]=n.top),u(n.language,n.value,!1,!0)}():function(){var e,n,t,r,a,i,c;if(!E.k)return _(R);for(r="",n=0,E.lR.lastIndex=0,t=E.lR.exec(R);t;)r+=_(R.substring(n,t.index)),a=E,i=t,c=f.cI?i[0].toLowerCase():i[0],(e=a.k.hasOwnProperty(c)&&a.k[c])?(d+=e[1],r+=u(e[0],_(t[0]))):r+=_(t[0]),n=E.lR.lastIndex,t=E.lR.exec(R);return r+_(R.substr(n))}(),R=""}function l(e){g+=e.cN?u(e.cN,"",!0):"",E=Object.create(e,{parent:{value:E}})}function r(e,n){if(R+=e,null==n)return s(),0;var t=function(e,n){var t,r,a;for(t=0,r=n.c.length;t<r;t++)if(v(n.c[t].bR,e))return n.c[t].endSameAsBegin&&(n.c[t].eR=(a=n.c[t].bR.exec(e)[0],new RegExp(a.replace(/[-\/\\^$*+?.()|[\]{}]/g,"\\$&"),"m"))),n.c[t]}(n,E);if(t)return t.skip?R+=n:(t.eB&&(R+=n),s(),t.rB||t.eB||(R=n)),l(t),t.rB?0:n.length;var r,a,i=function e(n,t){if(v(n.eR,t)){for(;n.endsParent&&n.parent;)n=n.parent;return n}if(n.eW)return e(n.parent,t)}(E,n);if(i){var c=E;for(c.skip?R+=n:(c.rE||c.eE||(R+=n),s(),c.eE&&(R=n));E.cN&&(g+=b),E.skip||E.sL||(d+=E.r),(E=E.parent)!==i.parent;);return i.starts&&(i.endSameAsBegin&&(i.starts.eR=i.eR),l(i.starts)),c.rE?0:n.length}if(r=n,a=E,!o&&v(a.iR,r))throw new Error('Illegal lexeme "'+n+'" for mode "'+(E.cN||"<unnamed>")+'"');return R+=n,n.length||1}var f=S(e);if(!f)throw new Error('Unknown language: "'+e+'"');m(f);var a,E=t||f,i={},g="";for(a=E;a!==f;a=a.parent)a.cN&&(g=u(a.cN,"",!0)+g);var R="",d=0;try{for(var c,p,M=0;E.t.lastIndex=M,c=E.t.exec(n);)p=r(n.substring(M,c.index),c[0]),M=c.index+p;for(r(n.substr(M)),a=E;a.parent;a=a.parent)a.cN&&(g+=b);return{r:d,value:g,language:e,top:E}}catch(e){if(e.message&&-1!==e.message.indexOf("Illegal"))return{r:0,value:_(n)};throw e}}function O(t,e){e=e||h.languages||u(N);var r={r:0,value:_(t)},a=r;return e.filter(S).filter(s).forEach(function(e){var n=C(e,t,!1);n.language=e,n.r>a.r&&(a=n),n.r>r.r&&(a=r,r=n)}),a.language&&(r.second_best=a),r}function B(e){return h.tabReplace||h.useBR?e.replace(t,function(e,n){return h.useBR&&"\n"===e?"<br>":h.tabReplace?n.replace(/\t/g,h.tabReplace):""}):e}function c(e){var n,t,r,a,i,c,o,u,s,l,f=function(e){var n,t,r,a,i=e.className+" ";if(i+=e.parentNode?e.parentNode.className:"",t=R.exec(i))return S(t[1])?t[1]:"no-highlight";for(n=0,r=(i=i.split(/\s+/)).length;n<r;n++)if(p(a=i[n])||S(a))return a}(e);p(f)||(h.useBR?(n=document.createElementNS("http://www.w3.org/1999/xhtml","div")).innerHTML=e.innerHTML.replace(/\n/g,"").replace(/<br[ \/]*>/g,"\n"):n=e,i=n.textContent,r=f?C(f,i,!0):O(i),(t=M(n)).length&&((a=document.createElementNS("http://www.w3.org/1999/xhtml","div")).innerHTML=r.value,r.value=function(e,n,t){var r=0,a="",i=[];function c(){return e.length&&n.length?e[0].offset!==n[0].offset?e[0].offset<n[0].offset?e:n:"start"===n[0].event?e:n:e.length?e:n}function o(e){a+="<"+d(e)+E.map.call(e.attributes,function(e){return" "+e.nodeName+'="'+_(e.value).replace('"',"&quot;")+'"'}).join("")+">"}function u(e){a+="</"+d(e)+">"}function s(e){("start"===e.event?o:u)(e.node)}for(;e.length||n.length;){var l=c();if(a+=_(t.substring(r,l[0].offset)),r=l[0].offset,l===e){for(i.reverse().forEach(u);s(l.splice(0,1)[0]),(l=c())===e&&l.length&&l[0].offset===r;);i.reverse().forEach(o)}else"start"===l[0].event?i.push(l[0].node):i.pop(),s(l.splice(0,1)[0])}return a+_(t.substr(r))}(t,M(a),i)),r.value=B(r.value),e.innerHTML=r.value,e.className=(c=e.className,o=f,u=r.language,s=o?g[o]:u,l=[c.trim()],c.match(/\bhljs\b/)||l.push("hljs"),-1===c.indexOf(s)&&l.push(s),l.join(" ").trim()),e.result={language:r.language,re:r.r},r.second_best&&(e.second_best={language:r.second_best.language,re:r.second_best.r}))}function o(){if(!o.called){o.called=!0;var e=document.querySelectorAll("pre code");E.forEach.call(e,c)}}function S(e){return e=(e||"").toLowerCase(),N[e]||N[g[e]]}function s(e){var n=S(e);return n&&!n.disableAutodetect}return a.highlight=C,a.highlightAuto=O,a.fixMarkup=B,a.highlightBlock=c,a.configure=function(e){h=l(h,e)},a.initHighlighting=o,a.initHighlightingOnLoad=function(){addEventListener("DOMContentLoaded",o,!1),addEventListener("load",o,!1)},a.registerLanguage=function(n,e){var t=N[n]=e(a);i(t),t.aliases&&t.aliases.forEach(function(e){g[e]=n})},a.listLanguages=function(){return u(N)},a.getLanguage=S,a.autoDetection=s,a.inherit=l,a.IR=a.IDENT_RE="[a-zA-Z]\\w*",a.UIR=a.UNDERSCORE_IDENT_RE="[a-zA-Z_]\\w*",a.NR=a.NUMBER_RE="\\b\\d+(\\.\\d+)?",a.CNR=a.C_NUMBER_RE="(-?)(\\b0[xX][a-fA-F0-9]+|(\\b\\d+(\\.\\d*)?|\\.\\d+)([eE][-+]?\\d+)?)",a.BNR=a.BINARY_NUMBER_RE="\\b(0b[01]+)",a.RSR=a.RE_STARTERS_RE="!|!=|!==|%|%=|&|&&|&=|\\*|\\*=|\\+|\\+=|,|-|-=|/=|/|:|;|<<|<<=|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\\?|\\[|\\{|\\(|\\^|\\^=|\\||\\|=|\\|\\||~",a.BE=a.BACKSLASH_ESCAPE={b:"\\\\[\\s\\S]",r:0},a.ASM=a.APOS_STRING_MODE={cN:"string",b:"'",e:"'",i:"\\n",c:[a.BE]},a.QSM=a.QUOTE_STRING_MODE={cN:"string",b:'"',e:'"',i:"\\n",c:[a.BE]},a.PWM=a.PHRASAL_WORDS_MODE={b:/\b(a|an|the|are|I'm|isn't|don't|doesn't|won't|but|just|should|pretty|simply|enough|gonna|going|wtf|so|such|will|you|your|they|like|more)\b/},a.C=a.COMMENT=function(e,n,t){var r=a.inherit({cN:"comment",b:e,e:n,c:[]},t||{});return r.c.push(a.PWM),r.c.push({cN:"doctag",b:"(?:TODO|FIXME|NOTE|BUG|XXX):",r:0}),r},a.CLCM=a.C_LINE_COMMENT_MODE=a.C("//","$"),a.CBCM=a.C_BLOCK_COMMENT_MODE=a.C("/\\*","\\*/"),a.HCM=a.HASH_COMMENT_MODE=a.C("#","$"),a.NM=a.NUMBER_MODE={cN:"number",b:a.NR,r:0},a.CNM=a.C_NUMBER_MODE={cN:"number",b:a.CNR,r:0},a.BNM=a.BINARY_NUMBER_MODE={cN:"number",b:a.BNR,r:0},a.CSSNM=a.CSS_NUMBER_MODE={cN:"number",b:a.NR+"(%|em|ex|ch|rem|vw|vh|vmin|vmax|cm|mm|in|pt|pc|px|deg|grad|rad|turn|s|ms|Hz|kHz|dpi|dpcm|dppx)?",r:0},a.RM=a.REGEXP_MODE={cN:"regexp",b:/\//,e:/\/[gimuy]*/,i:/\n/,c:[a.BE,{b:/\[/,e:/\]/,r:0,c:[a.BE]}]},a.TM=a.TITLE_MODE={cN:"title",b:a.IR,r:0},a.UTM=a.UNDERSCORE_TITLE_MODE={cN:"title",b:a.UIR,r:0},a.METHOD_GUARD={b:"\\.\\s*"+a.UIR,r:0},a});hljs.registerLanguage("json",function(e){var i={literal:"true false null"},n=[e.QSM,e.CNM],r={e:",",eW:!0,eE:!0,c:n,k:i},t={b:"{",e:"}",c:[{cN:"attr",b:/"/,e:/"/,c:[e.BE],i:"\\n"},e.inherit(r,{b:/:/})],i:"\\S"},c={b:"\\[",e:"\\]",c:[e.inherit(r)],i:"\\S"};return n.splice(n.length,0,t,c),{c:n,k:i,i:"\\S"}});
        // https://github.com/yckart/jquery.base64.js
        var base64=(function(){var b64="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",a256="",r64=[256],r256=[256],i=0,base64=function(){throw Error("base64 is a module.")};var UTF8={encode:function(strUni){var strUtf=strUni.replace(/[\u0080-\u07ff]/g,function(c){var cc=c.charCodeAt(0);return String.fromCharCode(192|cc>>6,128|cc&63)}).replace(/[\u0800-\uffff]/g,function(c){var cc=c.charCodeAt(0);return String.fromCharCode(224|cc>>12,128|cc>>6&63,128|cc&63)});return strUtf},decode:function(strUtf){var strUni=strUtf.replace(/[\u00e0-\u00ef][\u0080-\u00bf][\u0080-\u00bf]/g,function(c){var cc=((c.charCodeAt(0)&15)<<12)|((c.charCodeAt(1)&63)<<6)|(c.charCodeAt(2)&63);return String.fromCharCode(cc)}).replace(/[\u00c0-\u00df][\u0080-\u00bf]/g,function(c){var cc=(c.charCodeAt(0)&31)<<6|c.charCodeAt(1)&63;return String.fromCharCode(cc)});return strUni}};while(i<256){var c=String.fromCharCode(i);a256+=c;r256[i]=i;r64[i]=b64.indexOf(c);++i}function code(s,discard,alpha,beta,w1,w2){s=String(s);var buffer=0,i=0,length=s.length,result="",bitsInBuffer=0;while(i<length){var c=s.charCodeAt(i);c=c<256?alpha[c]:-1;buffer=(buffer<<w1)+c;bitsInBuffer+=w1;while(bitsInBuffer>=w2){bitsInBuffer-=w2;var tmp=buffer>>bitsInBuffer;result+=beta.charAt(tmp);buffer^=tmp<<bitsInBuffer}++i}if(!discard&&bitsInBuffer>0){result+=beta.charAt(buffer<<(w2-bitsInBuffer))}return result}base64.encode=function(plain,utf8encode){plain=utf8encode?UTF8.encode(plain):plain;plain=code(plain,false,r256,b64,8,6);return plain+"====".slice((plain.length%4)||4)};base64.decode=function(coded,utf8decode){coded=String(coded).split("=");var i=coded.length;do{--i;coded[i]=code(coded[i],true,r64,a256,6,8)}while(i>0);coded=coded.join("");return utf8decode?UTF8.decode(coded):coded};return base64})();
        // url_safe base64 decode & encode
        // fix: '_' -> '/', '-' -> '+'
        base64.url_safe_decode = function (e, utf8decode) {return base64.decode(e.replaceAll('_', '/').replaceAll('-', '+'), utf8decode)}
        base64.url_safe_encode = function (e, utf8decode) {return base64.encode(e, utf8decode).replaceAll('/', '_').replaceAll('+', '-').replaceAll('=', '')}
        var panel_source = document.querySelector("#data-source"),
        panel_results = document.querySelector("#results"),
        panel_draws = document.querySelector('#draws'),
        button_clear = document.querySelector("#clear"),
        button_func_save2jsonfile = document.querySelector('#save2jsonfile'),
        button_func_previewresult = document.querySelector('#preview-result') 

        var _results = []
        var _b64_format_re = /^(S{2}R:\/\/)[A-Z0-9_\-]+$/i
        function validB64Format(str) {
          return _b64_format_re.test(str)
        }
        function handleResults() {
          var contents = []
          for (var idx = 0; idx < _results.length; idx++) {
            var data = _results[idx]
            var content = "<h3>" + (idx+1) + "</h3>" 
            content += "<a href=\"" + data[7] + "\">直接导入（可能无效）</a>"
            content += "<ul class=\"server-config\">"
            content += "<li><span>地址</span><span>" + data[0] + "</span></li>"
            content += "<li><span>端口</span><span>" + data[1] + "</span></li>"
            content += "<li><span>加密方法</span><span>" + data[3] + "</span></li>"
            content += "<li><span>密码</span><span>" + data[5] + "</span></li>"
            content += "<li><span>备注</span><span>" + data[6]['remarks'] + "</span></li>"
            content += "<li><span>协议</span><span>" + data[2] + "</span></li>"
            content += "<li><span>协议参数</span><span>" + data[6]['protoparam'] + "</span></li>"
            content += "<li><span>混淆</span><span>" + data[4] + "</span></li>"
            content += "<li><span>混淆参数</span><span>" + data[6]['obfsparam'] + "</span></li>"
            content += "<li><span>分组</span><span>" + data[6]['group'] + "</span></li>"
            content += '</ul>'
            contents.push(content)
          }
          content = contents.join('')
          panel_results.innerHTML = content
        }
        function trans () {
          var results = []
          var data = (panel_source.value || '').trim()
          if (!data.startsWith('ssr')) {
            try {
              data = base64.url_safe_decode(data).trim()
            } catch (err) {
              console.log('decode error')
              return
            }
          }
          if ("" == data) {
            _results = []
            handleResults()
            return
          }
          results = data.split("\n")
          // valid format
          for (var i = 0; i < results.length; i ++) {
            if (!validB64Format(results[i])) {
              alert('请粘贴有效的数据')
              return;
            }
          }
          // echo
          panel_source.value = data
          results = results.map(function (e) {
            var item = e.trim().split("/")[2]
            var res = base64.url_safe_decode(item, true).split(':')
            var tmp = res[res.length-1].split('/')
            res[res.length-1] = base64.url_safe_decode(tmp[0], true)
            tmp = tmp[1].replace('?', '').split('&')
            var addon = {
              "obfsparam": "",
              "protoparam": "",
              "remarks": "",
              "group": ""
            }
            for (var i = 0; i < tmp.length; i++) {
              var s = tmp[i].split('=')
              switch(s[0]) {
              case 'obfsparam':
                addon['obfsparam'] = base64.url_safe_decode(s[1])
                break
              case 'protoparam':
                addon['protoparam'] = base64.url_safe_decode(s[1])
                break
              case 'remarks':
                addon['remarks_base64'] = s[1]
                addon['remarks'] = base64.url_safe_decode(s[1], true)
                break
              case 'group': 
                addon['group'] = base64.url_safe_decode(s[1], true)
                break
              }
            }
            res.push(addon)
            res.push(e)
            return res
          })
          _results = results
          handleResults()
        }
        panel_source.addEventListener("change", trans)
        button_clear.addEventListener("click", function (ev) {
          panel_source.value = ""
          trans()
          ev.preventDefault()
        })
        function _createConfig () {
          var configs = []
          for (var i = 0; i < _results.length; i++) {
            var data = _results[i]
            var config = {}
            config["remarks"] = data[6]['remarks']
            config["server"] = data[0]
            config["server_port"] = ~~data[1]
            config["server_udp_port"] = 0
            config["password"] = data[5]
            config["method"] = data[3]
            config["protocol"] = data[2]
            config["protocolparam"] = data[6]['protoparam']
            config["obfs"] = data[4]
            // fix: remove space or '\n'
            config["obfsparam"] = (data[6]['obfsparam'] + '').replace(/\s/g, '').replace(/([,\[\]\{\}%])/g, '%$1')
            config["remarks_base64"] = data[6]['remarks_base64']
            config["group"] = data[6]['group']
            config["enable"] = true
            config["udp_over_tcp"] = false
            configs.push(config)
          }
          return JSON.stringify({"configs": configs}, null, '  ')
        }
        button_func_previewresult.addEventListener('click', function () {
          
          var doc = document.createElement('div')

          // preview-doc style
          doc.style.boxShadow = '0 6px 7px -4px rgba(0,0,0,.2), 0 11px 15px 1px rgba(0,0,0,.14), 0 4px 20px 3px rgba(0,0,0,.12)'
          doc.style.position = "relative";
          doc.style.padding = "10px"
          doc.style.top = "20px";
          doc.style.minHeight = "500px"
          doc.style.backgroundColor = "#ccc"
          doc.style.borderRadius = "5px"
          panel_draws.appendChild(doc)
         
          var button_close = document.createElement('a')
          var ctx = document.createElement('pre')
          ctx.innerHTML = '<code class="json">' + _createConfig() + '</code>'
          hljs.highlightBlock(ctx.querySelector('code'))

          // button style
          button_close.style.position = "absolute";
          button_close.innerText = '关闭'
          button_close.style.display = "block"
          button_close.style.cursor = "pointer"
          button_close.style.textDecoration = "underline"
          button_close.style.top = "5px"
          button_close.style.right = "5px"
          doc.appendChild(button_close)
          doc.appendChild(ctx)
          button_close.addEventListener('click', function (ev) {
            panel_draws.removeChild(doc)
            ev.preventDefault()
          })
        })
        button_func_save2jsonfile.addEventListener('click', function (ev) {
          var urlObj = window.URL || window.webkitURL || window,
            blob = new Blob([_createConfig()])
          var link = document.createElementNS("http://www.w3.org/1999/xhtml", "a")
          link.href = urlObj.createObjectURL(blob)
          link.download = 'gui-config.json'

          // fake click!
          var e = document.createEvent('MouseEvents')
          e.initMouseEvent(
            "click", true, false, window, 0, 0, 0, 0, 0,
            false, false, false, false, 0, null
          )
          link.dispatchEvent(e)
          ev.preventDefault()
        })
      })()
    </script>
  </body>
</html>
/body>
</html>
>
