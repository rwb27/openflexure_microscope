var Base64={_keyStr:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",encode:function(e){var t="";var n,r,i,s,o,u,a;var f=0;e=Base64._utf8_encode(e);while(f<e.length){n=e.charCodeAt(f++);r=e.charCodeAt(f++);i=e.charCodeAt(f++);s=n>>2;o=(n&3)<<4|r>>4;u=(r&15)<<2|i>>6;a=i&63;if(isNaN(r)){u=a=64}else if(isNaN(i)){a=64}t=t+this._keyStr.charAt(s)+this._keyStr.charAt(o)+this._keyStr.charAt(u)+this._keyStr.charAt(a)}return t},decode:function(e){var t="";var n,r,i;var s,o,u,a;var f=0;e=e.replace(/[^A-Za-z0-9\+\/\=]/g,"");while(f<e.length){s=this._keyStr.indexOf(e.charAt(f++));o=this._keyStr.indexOf(e.charAt(f++));u=this._keyStr.indexOf(e.charAt(f++));a=this._keyStr.indexOf(e.charAt(f++));n=s<<2|o>>4;r=(o&15)<<4|u>>2;i=(u&3)<<6|a;t=t+String.fromCharCode(n);if(u!=64){t=t+String.fromCharCode(r)}if(a!=64){t=t+String.fromCharCode(i)}}t=Base64._utf8_decode(t);return t},_utf8_encode:function(e){e=e.replace(/\r\n/g,"\n");var t="";for(var n=0;n<e.length;n++){var r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r)}else if(r>127&&r<2048){t+=String.fromCharCode(r>>6|192);t+=String.fromCharCode(r&63|128)}else{t+=String.fromCharCode(r>>12|224);t+=String.fromCharCode(r>>6&63|128);t+=String.fromCharCode(r&63|128)}}return t},_utf8_decode:function(e){var t="";var n=0;var r=0,c1=0,c2=0;while(n<e.length){r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r);n++}else if(r>191&&r<224){c2=e.charCodeAt(n+1);t+=String.fromCharCode((r&31)<<6|c2&63);n+=2}else{c2=e.charCodeAt(n+1);c3=e.charCodeAt(n+2);t+=String.fromCharCode((r&15)<<12|(c2&63)<<6|c3&63);n+=3}}return t}}

var parsedBricks = []

function parseBrick(xml, obj, par) {
    // Recurse dependent bricks
    if($.inArray(obj.attr("id"), parsedBricks) == -1) {
        parsedBricks.push(obj.attr("id"));
        var el = $("<li />")
        var sublist = $("<ul/>")

        // Do recursion
        var subbed = 0;
        obj.find("function").each(function() {
            if($(this).find("implementation").attr("type") == "brick") {
                subbed = 1;
                reffed = xml.find("brick#"+$(this).find("implementation").attr("id"))
                parseBrick(xml, reffed, sublist)
            }
        })

        // Create element
        //var mu=0;
        if(subbed) {

            //el.append( $("<a/>").attr("href","#brick_"+obj.attr("id")) );
            el.append($("<strong/>").text(obj.find("name").text()));
            //el.append( $("<a/>").text("Overview").attr("href","#brick_"+obj.attr("id")) );
            //el.append( $("<a/>").attr("href","#brick_"+obj.attr("id")).attr("href","#brick_"+obj.attr("id")) );

            //sublist.el.append( $("<a/>").text("Overview").attr("href","#brick_"+obj.attr("id")) );
            el.append(sublist);
           // mu=1;
            //el.sublist.append.($("<li/>").( $("<a/>").text("Overview").attr("href","#brick_"+obj.attr("id")) ));
          		//console.log("#brick_"+obj.attr("id"));
        } else {
           // if (mu==1){
           //  el.append( $("<a/>").text("Overview").attr("href","#brick_"+obj.attr("id")) );
           //  par.append(el)
           //  mu=0;
           // }
            el.append($("<a />").text(obj.find("name").text()).attr("href","#brick_"+obj.attr("id")));
        }
        par.append(el)
    }
}
/**************************************/
/**
 * Return a string as "" if undefined
 */
function text0(t){
	if(t!=undefined && t.length!=undefined)
		return t;
	else
		return "";
}
/*************************************/
function getNameOfProject(db1,db2){
	//Get name of project
  var PName;

  db1.find('brick').each(function () {
  var id, name;
  id          = $(this).attr('id'); // or just `this.id`
  if(id===db2){
   PName=$(this).children('name').text();
   //console.log(PName);
  }
  //name        = $(this).children('name').text();
  //console.log(id);
  //console.log(name);
});
 return PName
}
/**************************************/
function renderBrick(db1,db2,dx){
	//Get name of project
  var PName;

  db1.find('brick').each(function () {
  var id, name;
  id = $(this).attr('id'); // or just `this.id`
  if(id===db2){
   PName=$(this).children('name').text();
   //console.log(PName);

   var anch=document.createElement("a");
 	 anch.setAttribute("name","brick_"+id);
 	 dx.appendChild(anch);

   var qj1a=document.createElement("div");
  	qj1a.setAttribute("class","mui-panel");

   var h1a=document.createElement("h1");
   h1a.appendChild(document.createTextNode(/*"Brick: "+*/PName));

   var pqja=document.createElement("p");
   pqja.setAttribute("align","left");
   pqja.appendChild(h1a);
   qj1a.appendChild(pqja);

   PAbs=text0($(this).children('abstract').text());
   if(PAbs!=""){
    var pqjb=document.createElement("p");
    pqjb.setAttribute("align","left");
    var text=document.createTextNode(PAbs);
    pqjb.appendChild(text);
    qj1a.appendChild(pqjb);
   }


   var bdescdiv=document.createElement("div");
   LDesc=text0($(this).children("long_description").text());

   if(LDesc!=""){
    var ldp=document.createElement("p");
    ldp.setAttribute("style", "text-align: left");
    var ldtext=document.createTextNode(LDesc);
    ldp.appendChild(ldtext);
    bdescdiv.appendChild(ldp);
   }

   qj1a.appendChild(bdescdiv);
   ///////////////////////////////////
   var mu=$(this).children('media');

   if (mu.children('file').length>0){

   if(mu.children('file').length===1){
   //console.log(mu.children('file').length);
   //console.log('In');
   //console.log(mu.children('file').attr('url'));

   var brknimg=document.createElement("div");
   var brickimgsrc=mu.children('file')[0].getAttribute('url');
   //console.log(brickimgsrc);

   var bimg=document.createElement("img");
			bimg.setAttribute("src",brickimgsrc);
  	bimg.setAttribute("width","100%");
   var brkimgp=document.createElement("p")
   brkimgp.setAttribute("align","left");
   brkimgp.appendChild(bimg);
   brknimg.appendChild(brkimgp);
   qj1a.appendChild(brknimg);
   }
   else{

     var qj=$(this).attr('id').concat("brk");
     //console.log(qj);
     var gcont=document.createElement("p");
     var mainimg=document.createElement("div");
    // mainimg.setAttribute("class","mui-row");

     var $brimgsrca= mu.children('file')[0];
     var brimgsrc= $brimgsrca.getAttribute('url');
     //console.log(brimgsrc)
     var bimg=document.createElement("img");
     bimg.setAttribute("id",qj);
     bimg.setAttribute("src",brimgsrc);
     bimg.setAttribute("width","100%");
     mainimg.appendChild(bimg);
     gcont.appendChild(mainimg);
     ///////////////////////////////////////
      var gmenu=document.createElement("div");
      gmenu.setAttribute("class","mui-row");
      gmenu.style.marginLeft = "0px"
      gmenu.style.marginRight = "0px"
     ////////////////////////////////////////
     ////////////////////////////////////////
     for (var j=0;j<mu.children('file').length;j++){
         var $muj=mu.children('file')[j];
         //console.log($muj.getAttribute('url'));
         var gimgj=document.createElement("img");
         gimgj.setAttribute("src",$muj.getAttribute('url'));
         gimgj.setAttribute("class","thumb");

         gimgj.onclick = function() { var a=$(this).attr("src");
         $('#'+qj).attr("src",$(this).attr("src")); };
         gmenu.appendChild(gimgj);

      }
      gcont.appendChild(gmenu);
      qj1a.appendChild(gcont);
    }

   }
   //dx.appendChild(qj1a);
 ////////////////////////////////////////////////////////////////////////////
 var stepnum = $(this).find('step').size();
 //console.log( stepnum );
 var qbrickj=$(this).attr('id').concat("brk");
 //console.log( qbrickj );
 if (stepnum>0){
   var aip=document.createElement("p");
   aip.setAttribute("style", "text-align: left");
   var aih2=document.createElement("h2");
   aih2.appendChild(document.createTextNode('Assembly Steps:'));
   aip.appendChild(aih2);
   qj1a.appendChild(aip);
//////////////////////////////
  var index=1;
  $( this ).find('step').each(function() {

    var stpjrow=document.createElement("div");
    stpjrow.setAttribute("class","mui-row");
    var stpjpleft=document.createElement("div");
    stpjpleft.setAttribute("class","mui-col-xs-6");
    var stpjpright=document.createElement("div");
    stpjpright.setAttribute("class","mui-col-xs-6");

    var aititle=document.createElement("b");
    aititle.appendChild(document.createTextNode("Step "+(index)+". "));
    var stepi=document.createTextNode(text0($(this).text()))
/////////////////////////////////////////////////////////////////////////////
   // console.log( index + ": " + $( this ).text() );
   // console.log($(this).find('file'));
    var mu=$(this).children('media');
    if (mu.children('file').length>0){
      if(mu.children('file').length===1){
       var brknimg=document.createElement("div");
       var brickimgsrc=mu.children('file')[0].getAttribute('url');
       //console.log(brickimgsrc);
       var bimg=document.createElement("img");
    			bimg.setAttribute("src",brickimgsrc);
      	bimg.setAttribute("width","100%");
       var brkimgp=document.createElement("p")
       brkimgp.setAttribute("align","left");
       brkimgp.appendChild(bimg);
       brknimg.appendChild(brkimgp);
       stpjpleft.appendChild(brknimg);
      }
      else{
       //Gallery main IMG

       //console.log( qbrickj );
       var qjx=qbrickj.concat("ai-step"+index.toString());
       //console.log(qjx);
       var mainimgx=document.createElement("div");
       var $brimgsrcax= mu.children('file')[0];
       var brimgsrcx= $brimgsrcax.getAttribute('url');
       //console.log(brimgsrcx)
       var bimgx=document.createElement("img");
       bimgx.setAttribute("id",qjx);
       bimgx.setAttribute("src",brimgsrcx);
       bimgx.setAttribute("width","100%");
       var gcontx=document.createElement("p");
       gcontx.setAttribute("align","left");
       mainimgx.appendChild(bimgx);
       gcontx.appendChild(mainimgx);

       var gmenux=document.createElement("div");
       gmenux.setAttribute("class","mui-row");
       gmenux.style.marginLeft = "0px"
       gmenux.style.marginRight = "0px"
       for (var j=0;j<mu.children('file').length;j++){
             var $mujx=mu.children('file')[j];
             //console.log($mujx.getAttribute('url'));
             var gimgjx=document.createElement("img");
             gimgjx.setAttribute("src",$mujx.getAttribute('url'));
             gimgjx.setAttribute("class","thumb");

             gimgjx.onclick = function() {
              var ax=$(this).attr("src");
              $('#'+qjx).attr("src",$(this).attr("src")); };

             gmenux.appendChild(gimgjx);
            //gcontx.appendChild(gmenux);
         //  stpjpleft.appendChild(gcontx);
        }
        gcontx.appendChild(gmenux);
        stpjpleft.appendChild(gcontx);
      }
    }
    stpjpright.appendChild(aititle);
    stpjpright.appendChild(stepi);
    stpjrow.appendChild(stpjpleft);
    stpjrow.appendChild(stpjpright);
    qj1a.appendChild(stpjrow);
    index=index+1;
 });

 }
 //BOM
  var h1a=document.createElement("h2");
  h1a.appendChild(document.createTextNode("Bill of Materials"));

  var pqja=document.createElement("p");
  pqja.setAttribute("align","left");
  pqja.appendChild(h1a);
  qj1a.appendChild(pqja);
  //dx.appendChild(qj1a);

  ////////////////////////////////
  var parts={}
  var count={}
  var keys=[]
  db1.find('physical_part').each(function () {
  var id, name;
  id = $(this).attr('id');
  name =$(this).children('description').text();
  parts[id]=name;
  count[id]=0;
  keys.push(id);
  //console.log(id);
  //console.log(name);

})
  //console.log(parts);

$(this).find('function').each(function(){
      var quant, id;
      quant= $(this).children('quantity').text();
      id=$(this).children('implementation').attr('id');
      //console.log(quant);
      //console.log(id);
      //console.log(parts[id]);
      //console.log(text0(parts[id]))
      if(text0(parts[id])!=""){
       //console.log("hello")
       count[id]+=parseInt(quant) }
})
  //console.log(count);
  var bomtable=document.createElement("table");
  bomtable.setAttribute("class","mui-table mui-table--bordered");
  var bomhead=document.createElement("thead");
  var hx1=document.createElement("tr");

  var ha1=document.createElement("th");
  var htxt1 = document.createTextNode("DESCRIPTION");
  ha1.appendChild(htxt1);
  hx1.appendChild(ha1);
  //bomhead.appendChild(hx1);

  var ha2=document.createElement("th");
  var htxt2 = document.createTextNode("QUANTITY");
  ha2.appendChild(htxt2);
  hx1.appendChild(ha2);
  //bomhead.appendChild(hx2);

  var ha3=document.createElement("th");
  var htxt3 = document.createTextNode("SUPPLIER");
  ha3.appendChild(htxt3);
  hx1.appendChild(ha3);

  bomhead.appendChild(hx1);
  bomtable.appendChild(bomhead);

  var bomBody = document.createElement("tbody");

  for (var i = 0; i < keys.length; i++) {
  // creates a table row
   if(count[keys[i]]>0){
    var row = document.createElement("tr");

    var cell1 = document.createElement("td");
    var cellText1 = document.createTextNode(parts[keys[i]]);
    ////////////////////
    var celltxta=document.createElement("a")
    celltxta.setAttribute("href","#"+parts[keys[i]]);
    celltxta.appendChild(cellText1);
    cell1.appendChild(celltxta);
    row.appendChild(cell1);
    ////////////////////
    //cell1.appendChild(cellText1);
    //row.appendChild(cell1);

    var cell2 = document.createElement("td");
    var cellText2 = document.createTextNode(count[keys[i]]);
    cell2.appendChild(cellText2);
    row.appendChild(cell2);

    var cell3 = document.createElement("td");
    var cellText3 = document.createTextNode("NA");
    cell3.appendChild(cellText3);
    row.appendChild(cell3);

    bomBody.appendChild(row);
   }
 }
  bomtable.appendChild(bomBody);
  qj1a.appendChild(bomtable);
  dx.appendChild(qj1a);
  }
 });
}

/***************************************/
function RenderManufactureList(db,dx,par){

 Mli=document.createElement("li");
 mi1menua=document.createElement("strong");
 //mi1menua.setAttribute("href","#TBOM");
 pplisttxt = document.createTextNode("Parts  and Manufacturing");
 //pplisttxt.setAttribute("class","nodebrick");
 mi1menua.appendChild(pplisttxt);
 Mli.appendChild(mi1menua);
 //bommenu.appendChild(bmi);
 //document.getElementById("bricklist").appendChild(bommenu);

 Mlij=document.createElement("ul");
 Mlij.setAttribute("id","pm-list");
 //Mli.appendChild(Mlij);

 db.find('physical_part').each(function () {

    var qj1a=document.createElement("div");
    qj1a.setAttribute("class","mui-panel");


    id = $(this).attr('id');
    PPName=$(this).children('description').text();
    //console.log(PPName);
    var h1a=document.createElement("h1");
    h1a.appendChild(document.createTextNode(PPName));
    qj1an=document.createElement("a")
    qj1an.setAttribute("name",PPName);
    qj1a.appendChild(qj1an);
    qj1a.appendChild(h1a);
    ////////////////////////////////////////////////////////////////////

    ptText1 = document.createTextNode(PPName);
    ptj=document.createElement("a");
    ptj.setAttribute("href","#"+PPName);
    ptj.appendChild(ptText1);

     var lipul=document.createElement("li");
     lipul.appendChild(ptj);
     Mlij.appendChild(lipul);

    ////////////////////////////////////////////////////////////////////
    var mu=$(this).children('media');

    if (mu.children('file').length>0){

    if(mu.children('file').length===1){
    //console.log(mu.children('file').length);
    //console.log('In');
    //console.log(mu.children('file').attr('url'));

    var brknimg=document.createElement("div");
    var brickimgsrc=mu.children('file')[0].getAttribute('url');
    //console.log(brickimgsrc);

    var bimg=document.createElement("img");
    bimg.setAttribute("src",brickimgsrc);
    bimg.setAttribute("width","100%");
    var brkimgp=document.createElement("p")
    brkimgp.setAttribute("align","left");
    brkimgp.appendChild(bimg);
    brknimg.appendChild(brkimgp);
    qj1a.appendChild(brknimg);
    }
    else{
      //Gallery main IMG
      var qj=$(this).attr('id').concat("brk");
      //console.log(qj);
      var gcont=document.createElement("p");
      var mainimg=document.createElement("div");
      //mainimg.setAttribute("class","mui-row");

      var $brimgsrca= mu.children('file')[0];
      var brimgsrc= $brimgsrca.getAttribute('url');
      //console.log(brimgsrc)
      var bimg=document.createElement("img");
      bimg.setAttribute("id",qj);
      bimg.setAttribute("src",brimgsrc);
      bimg.setAttribute("width","100%");
      mainimg.appendChild(bimg);
      gcont.appendChild(mainimg);
      ///////////////////////////////////////
       var gmenu=document.createElement("div");
       gmenu.setAttribute("class","mui-row");
       gmenu.style.marginLeft = "0px"
       gmenu.style.marginRight = "0px"
      ////////////////////////////////////////
      ////////////////////////////////////////
      for (var j=0;j<mu.children('file').length;j++){
          var $muj=mu.children('file')[j];
          //console.log($muj.getAttribute('url'));
          var gimgj=document.createElement("img");
          gimgj.setAttribute("src",$muj.getAttribute('url'));
          gimgj.setAttribute("class","thumb");

          gimgj.onclick = function() { var a=$(this).attr("src");
          $('#'+qj).attr("src",$(this).attr("src")); };
          gmenu.appendChild(gimgj);

       }
       gcont.appendChild(gmenu);
       qj1a.appendChild(gcont);
     }

    }
    /////////////////////////////////////////////////////////////////////
    var mi=$(this).find('manufacturing_instruction').each(function(){

     var stepnum = $(this).find('step').size();
     //console.log(stepnum);
     //console.log('Hello');
     /////////////

     if (stepnum>0){
       var aip=document.createElement("p");
       aip.setAttribute("style", "text-align: left");
       var aih2=document.createElement("h2");
       aih2.appendChild(document.createTextNode('Assembly Steps:'));
       aip.appendChild(aih2);
       qj1a.appendChild(aip);
    //////////////////////////////
      var index=1;
      $( this ).find('step').each(function() {

        var stpjrow=document.createElement("div");
        stpjrow.setAttribute("class","mui-row");
        var stpjpleft=document.createElement("div");
        stpjpleft.setAttribute("class","mui-col-xs-6");
        var stpjpright=document.createElement("div");
        stpjpright.setAttribute("class","mui-col-xs-6");

        var aititle=document.createElement("b");
        aititle.appendChild(document.createTextNode("Step "+(index)+". "));
        var stepi=document.createTextNode(text0($(this).text()))
    /////////////////////////////////////////////////////////////////////////////
       // console.log( index + ": " + $( this ).text() );
       // console.log($(this).find('file'));
        var mu=$(this).children('media');
        if (mu.children('file').length>0){
          if(mu.children('file').length===1){
           var brknimg=document.createElement("div");
           var brickimgsrc=mu.children('file')[0].getAttribute('url');
           //console.log(brickimgsrc);
           var bimg=document.createElement("img");
        			bimg.setAttribute("src",brickimgsrc);
          	bimg.setAttribute("width","100%");
           var brkimgp=document.createElement("p")
           brkimgp.setAttribute("align","left");
           brkimgp.appendChild(bimg);
           brknimg.appendChild(brkimgp);
           stpjpleft.appendChild(brknimg);
          }
          else{
           //Gallery main IMG

           //console.log( qbrickj );
           var qjx=qbrickj.concat("ai-step"+index.toString());
           //console.log(qjx);
           var mainimgx=document.createElement("div");
           var $brimgsrcax= mu.children('file')[0];
           var brimgsrcx= $brimgsrcax.getAttribute('url');
           //console.log(brimgsrcx)
           var bimgx=document.createElement("img");
           bimgx.setAttribute("id",qjx);
           bimgx.setAttribute("src",brimgsrcx);
           bimgx.setAttribute("width","100%");
           var gcontx=document.createElement("p");
           gcontx.setAttribute("align","left");
           mainimgx.appendChild(bimgx);
           gcontx.appendChild(mainimgx);

           var gmenux=document.createElement("div");
           gmenux.setAttribute("class","mui-row");
           gmenux.style.marginLeft = "0px"
           gmenux.style.marginRight = "0px"
           for (var j=0;j<mu.children('file').length;j++){
                 var $mujx=mu.children('file')[j];
                 //console.log($mujx.getAttribute('url'));
                 var gimgjx=document.createElement("img");
                 gimgjx.setAttribute("src",$mujx.getAttribute('url'));
                 gimgjx.setAttribute("class","thumb");

                 gimgjx.onclick = function() {
                  var ax=$(this).attr("src");
                  $('#'+qjx).attr("src",$(this).attr("src")); };

                 gmenux.appendChild(gimgjx);
                //gcontx.appendChild(gmenux);
             //  stpjpleft.appendChild(gcontx);
            }
            gcontx.appendChild(gmenux);
            stpjpleft.appendChild(gcontx);
          }
        }
        stpjpright.appendChild(aititle);
        stpjpright.appendChild(stepi);
        stpjrow.appendChild(stpjpleft);
        stpjrow.appendChild(stpjpright);
        qj1a.appendChild(stpjrow);
        index=index+1;
     });

     }


     ////////////
    });
    ////////////////////////////////////////////////////////////////////
    dx.appendChild(qj1a);
 });
 Mli.appendChild(Mlij);
 document.getElementById("bricklist").appendChild(Mli);

}
/**************************************/
function renderBOM(db,dx){
 /**
  * Add total bill of materials
  */

  var qj1a=document.createElement("div");
  qj1a.setAttribute("class","mui-panel");

  bmul=document.createElement("ul");
  bmi=document.createElement("li");
  qj1menua=document.createElement("a");
  qj1menua.setAttribute("href","#TBOM");
  pplisttxt = document.createTextNode("Bill of Materials");

  qj1menua.appendChild(pplisttxt);
  bmi.appendChild(qj1menua);
  //bmul.appendChild(qj1menua);
  bmul.appendChild(bmi);
  var blist=document.getElementById("bricklist");
  blist.setAttribute("class","nodebrick");
  blist.appendChild(bmul);

  var h1a=document.createElement("h1");
  h1a.appendChild(document.createTextNode("Bill of Materials"));
  qj1an=document.createElement("a")
  qj1an.setAttribute("name","TBOM");
  qj1a.appendChild(qj1an);

  var pqja=document.createElement("p");
  pqja.setAttribute("align","left");
  pqja.appendChild(h1a);
  qj1a.appendChild(pqja);
  dx.appendChild(qj1a);

  ////////////////////////////////
  var parts={}
  var count={}
  var keys=[]
  db.find('physical_part').each(function () {
  var id, name;
  id = $(this).attr('id');
  name =$(this).children('description').text();
  parts[id]=name;
  count[id]=0;
  keys.push(id);
  //console.log(id);
  //console.log(name);

})
  //console.log(parts);

  db.find('brick').each(function(){

    $(this).find('function').each(function(){
      var quant, id;
      quant= $(this).children('quantity').text();
      id=$(this).children('implementation').attr('id');
     // console.log(quant);
     // console.log(id);
     // console.log(parts[id]);
     // console.log(text0(parts[id]))
      if(text0(parts[id])!=""){
     //  console.log("hello")
       count[id]+=parseInt(quant) }
    })
  })

  //console.log(count);

  var bomtable=document.createElement("table");
  bomtable.setAttribute("class","mui-table mui-table--bordered");
  var bomhead=document.createElement("thead");
  var hx1=document.createElement("tr");

  var ha1=document.createElement("th");
  var htxt1 = document.createTextNode("DESCRIPTION");
  ha1.appendChild(htxt1);
  hx1.appendChild(ha1);
  //bomhead.appendChild(hx1);

  var ha2=document.createElement("th");
  var htxt2 = document.createTextNode("QUANTITY");
  ha2.appendChild(htxt2);
  hx1.appendChild(ha2);
  //bomhead.appendChild(hx2);

  var ha3=document.createElement("th");
  var htxt3 = document.createTextNode("SUPPLIER");
  ha3.appendChild(htxt3);
  hx1.appendChild(ha3);

  bomhead.appendChild(hx1);
  bomtable.appendChild(bomhead);

  var bomBody = document.createElement("tbody");

  for (var i = 0; i < keys.length; i++) {
  // creates a table row
    var row = document.createElement("tr");

    var cell1 = document.createElement("td");

    var cellText1 = document.createTextNode(parts[keys[i]]);
    var celltxta=document.createElement("a")
    celltxta.setAttribute("href","#"+parts[keys[i]]);
    celltxta.appendChild(cellText1);
    cell1.appendChild(celltxta);
    row.appendChild(cell1);
    /////////////////
    //qj1menua=document.createElement("a");
    //qj1menua.setAttribute("href","#TBOM");
    //pplisttxt = document.createTextNode("Bill of Materials");
    //pplisttxt.setAttribute("class","nodebrick");
    //qj1menua.appendChild(pplisttxt);
    /////////////////

    //cell1.appendChild(cellText1);
    //celltxta=document.createElement("a")
    //celltxta.setAttribute("href","#"+cellText1);
    //cell1.appendChild(celltxta);
    //row.appendChild(cell1);

    var cell2 = document.createElement("td");
    var cellText2 = document.createTextNode(count[keys[i]]);
    cell2.appendChild(cellText2);
    row.appendChild(cell2);

    var cell3 = document.createElement("td");
    var cellText3 = document.createTextNode("NA");
    cell3.appendChild(cellText3);
    row.appendChild(cell3);

    bomBody.appendChild(row);
 }

  bomtable.appendChild(bomBody);
  qj1a.appendChild(bomtable);
}
/**************************************/

function populatePage(db){


 db.find("brick").each(function(){
     parseBrick(db, $(this), $("#bricklist"))
 })

	//Set title based on the top brick name
	document.title=getNameOfProject(db, parsedBricks[0]);
 //
	var dx=document.getElementById("ccentre");

 for (var i=0; i < parsedBricks.length; i++) {
   renderBrick(db, parsedBricks[i],dx);
 }
 RenderManufactureList(db,dx,$("#partlistx"));
 renderBOM(db,dx);

}
/****************************************/
/**
 * Extract XML from a string
 */
function string2xml(txt){
	if (window.DOMParser){
		parser=new DOMParser();
		return parser.parseFromString(txt,"text/xml");
	} else { // Internet Explorer
		xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
		xmlDoc.async=false;
		xmlDoc.loadXML(txt);
		return xmlDoc;
	}
}
/****************************************/
function loadxml2(){
 //think this can be done less convoluted?
// console.log("hello");
	xmls = document.getElementById("hiddendata").children[0];
 xmls = new XMLSerializer().serializeToString(xmls);
 //xmls = string2xml(xmls).documentElement;
 //console.log(xmls)
 //xmls = $($.parseXML(Base64.decode(xmls)))
 xmlDoc = $.parseXML( xmls )
 $xml = $( xmlDoc )

 // xml = $($.(xmls)))
 console.log(xmls)
 console.log(xmlDoc)
 console.log($xml)

	populatePage($xml);
}
/**************************************/
