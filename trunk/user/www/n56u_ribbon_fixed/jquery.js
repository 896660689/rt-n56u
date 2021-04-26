/*! jQuery v1.7.2 jquery.com | jquery.org/license */

/* mobile ui */
var sc = document.createElement("meta");sc.setAttribute("name", "viewport");sc.setAttribute("content", "width=device-width, initial-scale=1, user-scalable=yes");document.head.appendChild(sc);
var style=document.createElement('style');
style.type='text/css';

style.innerHTML="@media screen and (max-width:800px){"
+".wrapper{width:100%}"
+".wrapper>.container-fluid,.wrapper>form>.container-fluid{padding:0 5px 5px 5px;margin:0}"
+".container-fluid{padding:none}"
+"#TopBanner .span6{width:auto;float:none;margin:5px;}"
+"#TopBanner .container-fluid{padding:0;margin:0}"
+"#logo{height:50px;position:fixed;top:0;left:90px;margin:0 auto;z-index:-1;}"
+".row-fluid>.span3,.row-fluid>.span9{float:none;width:auto;margin:0}"
//*menu*/
+".sidebar-nav.side_nav,#mainMenu{padding:none;background:none}"
+"#mainMenu{margin:0 0 10px;list-style:none;background:none repeat scroll 0 0 #F5F5F5}"
+"#mainMenu li {float: left; width:50%}"
+"#mainMenu li.active a,#mainMenu li:hover a{background: green;}"
+"#mainMenu li a{display:block;line-height:30px;text-align:center;border-left:1px solid #ccc;}"
+"#subMenu{clear:both;background:none}"
+"#subMenu a{display:block;float:left;width:33.3%;padding:0;line-height:30px}"
//*body menu*/
+".row-fluid .span9{float:none;width:auto;margin:0}"
+".row-fluid>.span2{float:none;width:auto;height:auto}"
+".row-fluid>.span2>.well{height:80px !important;padding:0 !important;margin:5px 0;position:relative;}"
+".row-fluid>.span2>.well>.table-big{margin:0 !important;transform:rotate(90deg);position:absolute;left:0;top:30px}"
+".row-fluid>.span2>.well>.table-big td{height:80px;padding:0 !important;margin:0 !important;border:none}"
+".row-fluid .span10{float:none;width:auto;margin:0}"
+"#menu_body.sitemap .nav-list{padding:0}"
+"#menu_body.sitemap .nav-list>li>a{margin:0;padding:0}"
+"#menu_body.sitemap table{font-size:0.9em;}"
+"#menu_body.sitemap table td{padding:3px}"
+"#menu_body.sitemap table td li{line-height:22px}"
+"#cpu_chart svg,#mem_chart svg{width:290px}"
+"}";

document.getElementsByTagName('head')[0].appendChild(style);
