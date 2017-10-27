/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// identity function for calling harmony imports with the correct context
/******/ 	__webpack_require__.i = function(value) { return value; };
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, {
/******/ 				configurable: false,
/******/ 				enumerable: true,
/******/ 				get: getter
/******/ 			});
/******/ 		}
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 7);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports) {

module.exports = React;

/***/ }),
/* 1 */
/***/ (function(module, exports) {

var g;

// This works in non-strict mode
g = (function() {
	return this;
})();

try {
	// This works if eval is allowed (see CSP)
	g = g || Function("return this")() || (1,eval)("this");
} catch(e) {
	// This works if the window reference is available
	if(typeof window === "object")
		g = window;
}

// g can still be undefined, but nothing to do about it...
// We return undefined, instead of nothing here, so it's
// easier to handle this case. if(!global) { ...}

module.exports = g;


/***/ }),
/* 2 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
/**
 * Deserialisation from XML
 *
 * The following methods tidy up the common code required to create objects from their XML representation.
 */
//const xml2js = require("xml2js"); //rwb27: tried adding XML import
const assert = __webpack_require__(6);
function stringOfHTMLFromXML(tag, xml, def = " ") {
    // retrieve the contents of a tag as a string, allowing HTML tags (for now, allows anything...?!)
    let elist = tagsFromXML(tag, xml);
    if (elist.length == 0) {
        // if the element is missing, return the default value if present, or throw an error.
        if (def != null) {
            return def;
        }
        else {
            throw (Error("Error: there was no '" + tag + "' tag, and one is required."));
        }
    }
    if (elist.length > 1)
        throw "Got multiple elements matching '" + tag + "' but exactly 1 was required.";
    let el = elist[0];
    return el.innerHTML;
}
/*
// it would be nice to handle strings in the same way as everything else - nice, but hard it seems!
class LoadableString extends string implements CopiableFromXML{
    copyFromXML(xml: XMLelement): void{
        
}*/
function attributeFromXML(attributeName, xml, def = "") {
    let attr = xml.getAttribute(attributeName);
    if (typeof attr === "string") {
        return attr; //if a string is found, return that.
    }
    else if (typeof def === "string") {
        return def; //if a reasonable default is given, use that.
    }
    else {
        //otherwise, raise an error (for the moment, dump debug info as well)
        console.log("Missing attribute '" + attributeName + "' in XML:");
        console.log(xml);
        console.log("attr:");
        console.log(attr);
        console.log("def:");
        console.log(def);
        console.log("typeof def:" + (typeof def));
        throw "Attribute " + attributeName + " is missing, but it is required.";
    }
}
function idFromXML(xml) {
    // convenience property to retrieve the id property of a tag
    return attributeFromXML("id", xml);
}
function tagsFromXML(tag, xml) {
    // return immediate children of an object (i.e. one level down the DOM tree)
    // which are of a specified tag type.  Surely there is a function for this
    // already???
    let elist = [];
    for (let i = 0; i < xml.children.length; i++) {
        if (xml.children[i] instanceof Element) {
            if (xml.children[i].tagName == tag)
                elist.push(xml.children[i]);
        }
    }
    return elist;
}
function tagFromXML(tag, xml) {
    // return a given tag from an XML element, ensuring there is at most one of it.
    //let elist = xml.children;//getElementsByTagName(tag); //retrieve nodes matching the given pathtry{
    let elist = tagsFromXML(tag, xml);
    if (elist.length == 1) {
        return elist[0];
    }
    else if (elist.length == 0) {
        console.log("Missing <" + tag + "> in XML element:");
        console.log(xml);
        throw "There is no <" + tag + "> tag in the XML";
    }
    else {
        console.log("multiple " + tag + " tags in the following XML (not allowed)");
        console.log(xml);
        console.log(elist);
        throw "Got multiple <" + tag + "> tags but exactly one is required.";
    }
}
function arrayFromXML(c, tag, xml, allowEmpty = true) {
    //Copy all XML tags with a given tag name ("key") into an array, converting each to the given type
    let elist = tagsFromXML(tag, xml); //retrieve the tags we want to turn into objects
    if (!allowEmpty)
        assert(elist.length > 0, "Error: couldn't find a node matching '" + tag + "'");
    //try{
    let objects = new Array();
    for (let i = 0; i < elist.length; i++) {
        let o = new c();
        o.copyFromXML(elist[i]);
        objects.push(o);
    }
    return objects;
    //}catch(e){
    //console.log("Error: couldn't load objects matching <'"+tag+"'> error: "+e);
    //}
}
function objectFromXML(c, tag, xml, allowEmpty = true) {
    // restore XML tags to objects, given the constructor of a class that contains the tags.
    let objects = arrayFromXML(c, tag, xml, allowEmpty);
    if (objects.length == 1) {
        return objects[0];
    }
    else if (objects.length == 0) {
        if (allowEmpty)
            return null;
        else
            throw "There were no <" + tag + "> tags, and one is required.";
    }
    else {
        throw "There were multiple <" + tag + "> tags, and at most one is required.";
    }
}
function stringArrayFromXML(tag, xml, allowEmpty = true) {
    // Return an array with the text values of all the tags of a given type
    // NB may have trouble if the text values are missing, or the XPath matches non-Element nodes
    let elist = tagsFromXML(tag, xml); //retrieve tags matching the given path
    if (!allowEmpty)
        assert(elist.length > 0, "Error: couldn't find a node matching '" + tag + "'");
    try {
        let strings = new Array();
        for (let i = 0; i < elist.length; i++) {
            strings.push(elist[i].textContent);
        }
        return strings;
    }
    catch (e) {
        console.log("Missing property: " + tag + " error: " + e);
    }
}
function stringFromXML(tag, xml, allowEmpty = true) {
    // Return the text stored in a given tag (specified by the tag), checking there's only one tag.
    let objects = stringArrayFromXML(tag, xml, allowEmpty);
    assert(objects.length <= 1, "Error: multiple nodes matched '" + tag + "' and at most one was required.");
    if (objects.length == 1)
        return objects[0];
    else
        return null;
}
/**
 * Bill of materials
 */
class Bom {
    constructor() {
        this.bom = new Map(); //part-id
    }
    /**
     * Add to BOM
     *
     * @param p The part
     * @param n Quantity
     */
    addPart(p, n) {
        if (n == 0)
            n = 1;
        if (this.bom.has(p))
            this.bom.set(p, this.bom.get(p) + n);
        else
            this.bom.set(p, n);
    }
    addBom(b, n) {
        if (n == 0)
            n = 1;
        for (let p of b.bom.keys()) {
            this.addPart(p, b.bom.get(p) * n);
        }
    }
    isEmpty() {
        return this.bom.size == 0;
    }
}
exports.Bom = Bom;
/**
 * One author
 */
class Author {
    /**
     * Copy (for parsing)
     */
    copyfrom(o) {
        Object.assign(this, o);
    }
    copyFromXML(xml) {
        this.id = idFromXML(xml); //do I want to do this??
        this.name = stringFromXML("name", xml);
        this.email = stringFromXML("email", xml);
        this.orcid = stringFromXML("orcid", xml);
        this.affiliation = stringFromXML("affiliation", xml);
    }
}
exports.Author = Author;
/**
 * One brick
 */
class Brick {
    constructor() {
        this.mapFunctions = new Map();
    }
    /**
     * Get BOM as only what this particular brick contains
     */
    getBom(proj, recursive, recursionPrefix = "") {
        var bom = new Bom();
        //console.log("functions");
        //console.log(this.functions);
        for (let func of this.mapFunctions.values()) {
            func.implementations.forEach(function (imp) {
                if (imp.isPart()) {
                    var p = imp.getPart(proj);
                    //bom.addPart(p.id, +func.quantity);
                    bom.addPart(p.id, imp.quantity);
                }
                else if (imp.isBrick()) {
                    if (recursive) {
                        let brick = imp.getBrick(proj);
                        var b = brick.getBom(proj, true, recursionPrefix + ">" + brick.name);
                        //bom.addBom(b,+func.quantity);                    
                        bom.addBom(b, imp.quantity);
                    }
                }
                else {
                    console.log("bad imp type" + imp.type);
                }
            });
        }
        console.log("bom " + recursionPrefix);
        console.log(bom);
        return bom;
    }
    /**
     * Get bricks this brick has as direct children
     */
    getChildBricks() {
        var referenced = new Set();
        //this.mapFunctions.values().forEach(function(func:BrickFunction){
        for (let func of this.mapFunctions.values()) {
            func.implementations.forEach(function (imp) {
                if (imp.isBrick()) {
                    referenced.add(imp.id);
                }
            });
        }
        return referenced;
    }
    /**
     * Copy (for parsing)
     */
    copyfrom(o) {
        Object.assign(this, o);
        this.functions = [];
        var t = this;
        //Copy sub-bricks and functions
        o.functions.forEach(function (ofunc, index) {
            var f = new BrickFunction();
            f.copyfrom(ofunc);
            //t.functions.push(f);
            f.id = "" + index;
            t.mapFunctions.set("" + index, f);
        });
    }
    copyFromXML(xml) {
        this.id = idFromXML(xml); //do I want to do this??
        this.name = stringFromXML("name", xml);
        this.abstract = stringFromXML("abstract", xml);
        this.long_description = tagFromXML("long_description", xml);
        this.notes = tagFromXML("notes", xml);
        this.license = stringFromXML("license", xml);
        this.authors = stringArrayFromXML("authors", xml);
        this.functions = arrayFromXML(BrickFunction, "function", xml);
        this.instructions = arrayFromXML(StepByStepInstruction, "assembly_instruction", xml);
        this.files = mediaFilesFromXML(xml);
        for (let i in this.functions) {
            this.mapFunctions.set("" + i, this.functions[i]);
        }
    }
}
exports.Brick = Brick;
/**
 * One function for a brick
 */
class BrickFunction {
    copyfrom(o) {
        Object.assign(this, o);
        this.implementations = [];
        o.implementations.forEach((oi, index) => {
            var f = new FunctionImplementation();
            f.copyfrom(oi);
            this.implementations.push(f);
        });
    }
    copyFromXML(xml) {
        this.id = idFromXML(xml); //do I want to do this??
        this.description = stringFromXML("description", xml);
        this.designator = stringFromXML("designator", xml);
        this.quantity = stringFromXML("quantity", xml);
        this.implementations = arrayFromXML(FunctionImplementation, "implementation", xml);
    }
}
exports.BrickFunction = BrickFunction;
class FunctionImplementation {
    isPart() {
        return this.type == "part";
    }
    isBrick() {
        return this.type == "brick";
    }
    getPart(proj) {
        return proj.getPartByName(this.id); //parts[+this.id];
    }
    getBrick(proj) {
        return proj.getBrickByName(this.id); //bricks[+this.id];
    }
    copyfrom(oi) {
        Object.assign(this, oi);
        /*this.id=oi.id;
        this.quantity=oi.quantity;
        this.type=oi.type;*/
    }
    copyFromXML(xml) {
        this.id = idFromXML(xml); //do I want to do this??
        this.type = attributeFromXML("type", xml, null);
        if (this.type == "physical_part") {
            this.type = "part";
        }
        this.quantity = Number(attributeFromXML("quantity", xml, "1"));
    }
}
exports.FunctionImplementation = FunctionImplementation;
/**
 * One associated file
 */
class MediaFile {
    copyFromXML(xml) {
        this.url = attributeFromXML("url", xml, null);
    }
}
exports.MediaFile = MediaFile;
function mediaFilesFromXML(xml) {
    //convenience function for populating files lists from  Element
    let media = tagFromXML("media", xml);
    //return [];
    //try{
    return arrayFromXML(MediaFile, "file", media);
    //}catch(e){
    //    return [];
    //}
}
/**
 * One part
 */
class Part {
    copyfrom(o) {
        Object.assign(this, o);
    }
    copyFromXML(xml) {
        this.id = idFromXML(xml);
        this.name = stringFromXML("name", xml);
        this.description = stringFromXML("description", xml);
        if (this.name == null || this.name.length == 0) {
            this.name = this.description;
        }
        this.supplier = stringFromXML("supplier", xml);
        this.supplier_part_num = stringFromXML("supplier_part_num", xml);
        this.manufacturer_part_num = stringFromXML("manufacturer_part_num", xml);
        this.url = stringFromXML("url", xml);
        this.material_amount = stringFromXML("material_amount", xml);
        this.material_unit = stringFromXML("material_unit", xml);
        this.files = mediaFilesFromXML(xml);
        this.manufacturing_instruction = objectFromXML(StepByStepInstruction, "manufacturing_instruction", xml);
    }
}
exports.Part = Part;
/**
 * One step-by-step instruction
 */
class StepByStepInstruction {
    copyFromXML(xml) {
        this.name = attributeFromXML("name", xml);
        this.steps = arrayFromXML(AssemblyStep, "step", xml); //load correctly from XML file
        //this.steps = [{components:[], description:"test step", files:[]}];//this works (untyped objects)
        /*let teststep = new AssemblyStep();
        teststep.files = [];
        teststep.components = [];
        teststep.description = "test step with correct type";
        this.steps = [teststep];//arrayFromXML(AssemblyStep, "step", xml);*/
    }
}
exports.StepByStepInstruction = StepByStepInstruction;
/**
 * One assembly step (or any instruction step)
 */
class AssemblyStep {
    copyFromXML(xml) {
        this.description = tagFromXML("description", xml);
        this.files = mediaFilesFromXML(xml);
        this.components = arrayFromXML(AssemblyStepComponent, "component", xml);
    }
}
exports.AssemblyStep = AssemblyStep;
/**
 * reference - to be removed?
 */
class AssemblyStepComponent {
    copyFromXML(xml) {
        this.quantity = stringFromXML("quantity", xml);
        this.id = idFromXML(xml);
    }
}
exports.AssemblyStepComponent = AssemblyStepComponent;
class BrickTree {
    constructor() {
        this.children = [];
    }
}
exports.BrickTree = BrickTree;
/**
 * One docubricks project
 */
class Project {
    constructor() {
        this.bricks = [];
        this.parts = [];
        this.authors = [];
        //    public mapBricks:Map<string,Brick>=new Map<string,Brick>();    //discards order. SHOULD use bricks[]
        this.mapParts = new Map();
        this.mapAuthors = new Map();
        this.base_url = "./project/";
    }
    getBrickByName(id) {
        for (let b of this.bricks)
            if (b.id == id)
                return b;
        //var b:Brick=this.mapBricks.get(id)
        //if(b===undefined){
        console.error("---- no such brick \"" + id + "\"");
        console.error(this.bricks);
        //for(let of of this.bricks)
        //    console.error(i);
        return null;
        //}
        //return b;
    }
    getPartByName(id) {
        if (this.mapParts.get(id) == null) {
            console.log("BAD PART ID: " + id);
        }
        return this.mapParts.get(id);
    }
    getAuthorById(id) {
        return this.mapAuthors.get(id);
    }
    /**
     * Get all the roots. Hopefully only one
     */
    getRootBricks() {
        //See what is referenced
        var referenced = new Set();
        //for(let b of this.mapBricks.values()){
        for (let b of this.bricks) {
            for (let c of b.getChildBricks())
                referenced.add(c);
        }
        //Pick unreferenced bricks as roots
        var roots = [];
        for (let b of this.bricks)
            if (!referenced.has(b.id))
                roots.push(b.id);
        //Backup: Pick anything as the root. Not great but better
        if (roots.length == 0)
            for (let b of this.bricks) {
                roots.push(b.id);
                break;
            }
        return roots;
    }
    getBrickTree() {
        var thetree = [];
        //Pick unreferenced bricks as roots
        var roots = this.getRootBricks();
        var referenced = new Set();
        for (let b of this.bricks)
            if (!referenced.has(b.id))
                thetree.push(this.getBrickTreeR(this, b, referenced));
        return thetree;
    }
    getBrickTreeR(thisProject, thisbrick, referenced) {
        var t = new BrickTree();
        t.brick = thisbrick; //this.mapBricks.get(thisbrick);//bricks[+thisbrick];
        referenced.add(thisbrick.id);
        var children = thisbrick.getChildBricks();
        for (let c of children) {
            if (!referenced.has(c)) {
                t.children.push(thisProject.getBrickTreeR(thisProject, thisProject.getBrickByName(c), referenced));
            }
        }
        return t;
    }
    /**
     * For parsing only
     */
    copyfrom(o) {
        //Copy bricks
        for (let ob of o.bricks) {
            //var ob:Brick=o.bricks[index];
            var b = new Brick();
            b.copyfrom(ob);
            //var si:string=""+index;
            //b.id=si;
            this.bricks.push(b);
            //this.mapBricks.set(si,b);
        }
        ;
        //Copy parts
        for (let op of o.parts) {
            var p = new Part();
            p.copyfrom(op);
            this.mapParts.set(p.id, p);
        }
        ;
        //Copy authors
        for (let oa of o.authors) {
            var a = new Author();
            a.copyfrom(oa);
            this.mapAuthors.set(a.id, a);
        }
        ;
    }
    copyFromXML(xml) {
        console.log("Parsing bricks");
        this.bricks = arrayFromXML(Brick, "brick", xml);
        console.log("Parsing parts");
        this.parts = arrayFromXML(Part, "physical_part", xml);
        console.log("Parsing authors");
        this.authors = arrayFromXML(Author, "author", xml);
        console.log("Parsed project, building maps...");
        for (let p of this.parts) {
            this.mapParts.set(p.id, p);
        }
        for (let a of this.authors) {
            this.mapAuthors.set(a.id, a);
        }
        console.log("Project successfully reconstructed from XML");
    }
    /**
     * Get the name of the project - use the name of the root brick
     */
    getNameOfProject() {
        var roots = this.getRootBricks();
        if (roots.length > 0) {
            var root = this.getBrickByName(roots[0]);
            return root.name;
        }
        else
            return "";
    }
}
exports.Project = Project;
function docubricksFromJSON(s) {
    var proj = JSON.parse(s);
    var realproj = new Project();
    realproj.copyfrom(proj);
    console.log("successfully created docubricks project ", realproj);
    return realproj;
}
exports.docubricksFromJSON = docubricksFromJSON;
function docubricksFromDOM(xmldoc) {
    //Create a new project from an XML document (already parsed into a DOM)
    let proj = new Project();
    //Copy bricks
    proj.copyFromXML(xmldoc.documentElement);
    console.log("successfully created docubricks project ", proj);
    return proj;
}
exports.docubricksFromDOM = docubricksFromDOM;
function docubricksFromXML(s, callback) {
    let xmldoc = new DOMParser().parseFromString(s, "application/xml");
    let proj = new Project();
    //Copy bricks
    proj.copyFromXML(xmldoc.documentElement);
    console.log("successfully created docubricks project ", proj);
    callback(proj); //I really hate JS callbacks :(
}
exports.docubricksFromXML = docubricksFromXML;
function docubricksFromXMLSync(s) {
    let xmldoc = new DOMParser().parseFromString(s, "application/xml");
    let proj = new Project();
    //Copy bricks
    proj.copyFromXML(xmldoc.documentElement);
    console.log("successfully created docubricks project ", proj);
    return proj; //I really hate JS callbacks :(
}
exports.docubricksFromXMLSync = docubricksFromXMLSync;
// WEBPACK FOOTER //
// ./src/docubricks.ts 


/***/ }),
/* 3 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
const React = __webpack_require__(0);
//import renderHTML from 'react-render-html';
//State is never set so we use the 'undefined' type. //rwb27: what does this comment refer to...??
function renderHTMLFromString(htmlstring) {
    if (typeof htmlstring === "string") {
        return htmlstring;
    }
    else if (htmlstring instanceof Element) {
        //
    }
}
class DocubricksProject extends React.Component {
    /**
     * Render the tree of bricks
     */
    renderBrickTree(t) {
        var mnodes = [];
        for (let n of t) {
            mnodes.push(this.renderBrickTreeR(n));
        }
        return React.createElement("ul", null, mnodes);
    }
    renderBrickTreeR(t) {
        var proj = this.props.proj;
        var mnodes = [];
        for (let c of t.children) {
            mnodes.push(React.createElement("li", { key: "treechild_" + c.brick.id }, this.renderBrickTreeR(c)));
        }
        return React.createElement("div", { key: "treenode_" + t.brick.id },
            React.createElement("a", { href: "#brick_" + t.brick.id }, t.brick.name),
            React.createElement("ul", null, mnodes));
    }
    /**
     * Main rendering function
     */
    render() {
        var proj = this.props.proj;
        document.title = "DocuBricks - " + proj.getNameOfProject();
        var brickTree = proj.getBrickTree();
        var itemsAuthors = [];
        for (let a of proj.mapAuthors.values()) {
            itemsAuthors.push(React.createElement(Author, { key: "author_" + a.id, proj: proj, authorid: a.id }));
        }
        var itemsBricks = [];
        for (let b of proj.bricks) {
            itemsBricks.push(React.createElement("div", { key: b.id },
                " ",
                React.createElement(Brick, { proj: proj, brickid: b.id })));
        }
        var itemsParts = [];
        for (let b of proj.mapParts.values()) {
            itemsParts.push(React.createElement("div", { key: b.id },
                " ",
                React.createElement(Part, { proj: proj, partid: b.id })));
        }
        var itemsTotalBom = [];
        var roots = proj.getRootBricks();
        if (roots.length > 0) {
            var root = proj.getBrickByName(roots[0]);
            var bom = root.getBom(proj, true);
            itemsTotalBom.push(React.createElement("div", null,
                React.createElement("div", { className: "divbom" },
                    React.createElement("h1", { id: "bom" }, "Total bill of materials for this project")),
                React.createElement(BomList, { proj: proj, bom: bom })));
        }
        else {
            console.log("no root brick found for bom");
        }
        var projectid = getQueryStringValue("id");
        var downloadlink = "DownloadZip?id=" + projectid;
        return React.createElement("div", { className: "all" },
            React.createElement("div", { className: "page-container" },
                React.createElement("div", { className: "navbar navbar-default navbar-fixed-top", role: "navigation" },
                    React.createElement("div", { className: "container" },
                        React.createElement("div", { className: "navbar-header" },
                            React.createElement("button", { type: "button", className: "navbar-toggle", "data-toggle": "offcanvas", "data-target": ".sidebar-nav" },
                                React.createElement("span", { className: "icon-bar" }),
                                React.createElement("span", { className: "icon-bar" }),
                                React.createElement("span", { className: "icon-bar" })),
                            React.createElement("a", { className: "navbar-brand", href: "./" }, "DocuBricks")))),
                React.createElement("div", { className: "container" },
                    React.createElement("div", { className: "row row-offcanvas row-offcanvas-left" },
                        React.createElement("div", { className: "col-xs-12 col-sm-4 sidebar-offcanvas no-print", id: "sidebar", role: "navigation" },
                            React.createElement("ul", { className: "nav", "data-spy": "affix" },
                                React.createElement("li", null,
                                    React.createElement("a", { href: downloadlink }, "Download project")),
                                React.createElement("li", null,
                                    React.createElement("a", { className: "accordion-toggle", id: "btn-1", "data-toggle": "collapse", "data-target": "#submenu1", "aria-expanded": "true" }, "Bricks"),
                                    React.createElement("li", { className: "nav collapse in ", id: "submenu1", role: "menu", "aria-labelledby": "btn-1" }, this.renderBrickTree(brickTree))),
                                React.createElement("li", null,
                                    React.createElement("a", { href: "#partstart" }, "Parts")),
                                React.createElement("li", null,
                                    React.createElement("a", { href: "#bom" }, "Bill of materials")),
                                React.createElement("li", null,
                                    React.createElement("a", { href: "#authors" }, "Authors")))),
                        React.createElement("div", { className: "col-xs-12 col-sm-8", id: "main-content" },
                            React.createElement("div", null,
                                React.createElement("div", { id: "brickstart" }, itemsBricks),
                                React.createElement("div", { id: "partstart" }, itemsParts),
                                React.createElement("div", { className: "brickdiv" },
                                    React.createElement("h3", { id: "authors" }, "Authors")),
                                React.createElement("table", null,
                                    React.createElement("thead", null,
                                        React.createElement("tr", null,
                                            React.createElement("th", null, "Name"),
                                            React.createElement("th", null, "E-mail"),
                                            React.createElement("th", null, "Affiliation"),
                                            React.createElement("th", null, "ORCID"))),
                                    React.createElement("tbody", null, itemsAuthors)),
                                itemsTotalBom))))));
    }
}
exports.DocubricksProject = DocubricksProject;
class Brick extends React.Component {
    render() {
        var proj = this.props.proj;
        var brickid = this.props.brickid;
        var brick = proj.getBrickByName(brickid);
        var brickkey = "brick" + this.props.brickid;
        const pStyle = {
            textAlign: "left" //text-align
        };
        var mnodes = [];
        var addField = function (name, value) {
            if (value != "")
                mnodes.push(React.createElement("p", { key: brickkey + "_" + name },
                    React.createElement("b", null,
                        name,
                        ": "),
                    value));
        };
        if (typeof brick.abstract != 'undefined') {
            addField("Abstract", renderDescription(brick.abstract));
        }
        addField("Description", renderDescription(brick.long_description));
        mnodes.push(React.createElement("p", { key: brickkey + "_brickabstract" }, renderDescription(brick.abstract)));
        mnodes.push(React.createElement(Files, { key: brickkey + "_files", proj: proj, files: brick.files, basekey: brickkey }));
        addField("License", brick.license);
        addField("Notes", renderDescription(brick.notes));
        //Authors
        if (brick.authors.length != 0) {
            var alist = "";
            for (let aid of brick.authors) {
                var a = proj.getAuthorById(aid);
                if (alist.length != 0) {
                    alist = alist + ", " + a.name;
                }
                else
                    alist = a.name;
            }
            addField("Authors", alist);
        }
        //Functions & implementations
        var reqnodes = [];
        for (let func of brick.mapFunctions.values()) {
            var fnodes = [];
            for (let imp of func.implementations) {
                var impend = "";
                if (fnodes.length != 0)
                    fnodes.push(React.createElement("b", null, ", "));
                if (imp.isPart()) {
                    var ip = imp.getPart(proj);
                    fnodes.push(React.createElement("a", { href: "#part_" + imp.id },
                        ip.name,
                        " ",
                        React.createElement("b", null,
                            "x ",
                            imp.quantity)));
                }
                else if (imp.isBrick()) {
                    var ib = imp.getBrick(proj);
                    fnodes.push(React.createElement("a", { href: "#brick_" + imp.id },
                        ib.name,
                        " ",
                        React.createElement("b", null,
                            "x ",
                            imp.quantity)));
                }
            }
            var desc = "";
            if (func.description != "")
                desc = func.description + ": ";
            reqnodes.push(React.createElement("li", null,
                React.createElement("b", null, desc),
                fnodes));
        }
        var reqnodes2 = [];
        if (reqnodes.length != 0) {
            reqnodes2 = [React.createElement("div", null,
                    React.createElement("b", null, "Requires:"),
                    React.createElement("ul", null, reqnodes))];
        }
        //The bill of materials
        /*
        var bom:Docubricks.Bom = brick.getBom(proj,false);
        if(!bom.isEmpty()){
            mnodes.push(
                    <div>
                        <div className="divbrickbom">
                            <h3>Materials for this brick</h3>
                        </div>
                        <BomList proj={proj} bom={bom}/>
                    </div>);
        }
        */
        //All the instructions
        var instrnodes = [];
        for (let instr of brick.instructions) {
            instrnodes.push(React.createElement("div", { key: brickkey + "_" + instr.name },
                React.createElement(InstructionList, { proj: proj, brick: brick, part: null, instr: instr })));
        }
        var ret = React.createElement("div", null,
            React.createElement("div", { className: "brickdiv" },
                React.createElement("h1", { id: "brick_" + brickid }, brick.name)),
            mnodes,
            reqnodes2,
            instrnodes);
        return ret;
    }
}
exports.Brick = Brick;
class Part extends React.Component {
    render() {
        var proj = this.props.proj;
        var partid = this.props.partid;
        var part = proj.getPartByName(partid);
        var partkey = "part" + partid;
        ////////////////////////////xpublic files: MediaFile[];
        var mnodes = [];
        var addField = function (name, value) {
            if (value != "")
                mnodes.push(React.createElement("p", { key: partkey + "_" + name },
                    React.createElement("b", null,
                        name,
                        ": "),
                    value));
        };
        addField("Description", part.description);
        mnodes.push(React.createElement(Files, { key: partkey + "_files", proj: proj, files: part.files, basekey: partkey }));
        addField("Supplier", part.supplier);
        addField("Supplier catalog #", part.supplier_part_num);
        addField("Manufacturer catalog #", part.manufacturer_part_num);
        if (part.url != "")
            mnodes.push(React.createElement("p", { key: partkey + "_url" },
                React.createElement("b", null, "URL: "),
                formatURL(part.url)));
        if (part.material_amount != "")
            addField("Material usage", part.material_amount + " " + part.material_unit);
        //All the instructions
        if (part.manufacturing_instruction.steps.length != null) {
            mnodes.push(React.createElement("div", { key: partkey + "_instr" },
                React.createElement(InstructionList, { proj: proj, brick: null, part: part, instr: part.manufacturing_instruction })));
        }
        var ret = React.createElement("div", null,
            React.createElement("div", { className: "partdiv" },
                React.createElement("h3", { id: "part_" + partid },
                    "Part: ",
                    part.name)),
            mnodes);
        return ret;
    }
}
exports.Part = Part;
class Author extends React.Component {
    render() {
        var proj = this.props.proj;
        var author = proj.getAuthorById(this.props.authorid);
        return React.createElement("tr", { key: "authorrow_" + author.id },
            React.createElement("td", null, author.name),
            React.createElement("td", null, author.email),
            React.createElement("td", null, author.affiliation),
            React.createElement("td", null, author.orcid));
    }
}
exports.Author = Author;
class InstructionList extends React.Component {
    render() {
        var proj = this.props.proj;
        var brick = this.props.brick;
        var instr = this.props.instr;
        var key;
        if (brick != null)
            key = "instrBrick" + brick.id + "_instr" + instr.name;
        else
            key = "instrPart" + this.props.part.id + "_instr" + instr.name;
        var snodes = [];
        var curstep = 1;
        for (let step of instr.steps) {
            var stepkey = key + "_" + curstep;
            snodes.push(React.createElement("div", { className: "step", key: stepkey },
                React.createElement("hr", null),
                React.createElement("nav", { className: "image-col" },
                    React.createElement(Files, { proj: proj, files: step.files, basekey: stepkey })),
                React.createElement(InstructionStep, { listKey: key, stepIndex: curstep, step: step })));
            const divclear = { clear: "both" };
            snodes.push(React.createElement("div", { key: stepkey + "_end", style: divclear }));
            curstep++;
        }
        var instrName = instr.name || '';
        var instrtitle = "Instruction: " + instrName;
        if (instr.name == "assembly")
            instrtitle = "Assembly instruction";
        if (snodes.length > 0)
            return React.createElement("div", { key: key + "_main" },
                React.createElement("h3", null, instrtitle),
                snodes);
        else
            return React.createElement("div", { key: key + "_main" });
    }
}
exports.InstructionList = InstructionList;
function renderDescription(description) {
    if (typeof (description) == "string") {
        return description;
    }
    else {
        return domNodeChildrenToReactElements(description);
    }
}
function domNodeChildrenToReactElements(domNode) {
    let nodes = [];
    for (let i = 0; i < domNode.childNodes.length; i++) {
        let childNode = domNode.childNodes[i];
        if (childNode.nodeType == 3) {
            //we have a text node, so push it into the list as a string
            nodes.push(childNode.nodeValue);
        }
        else if (childNode.nodeType == 1) {
            //we have an XML Element
            let allowedTags = ["b", "i", "ul", "ol", "li", "p", "a", "pre", "code"];
            if (allowedTags.indexOf(childNode.nodeName) >= 0) {
                let attributes = {};
                for (let j = 0; j < childNode.attributes.length; j++) {
                    let attrNode = childNode.attributes[j];
                    attributes[attrNode.nodeName] = attrNode.nodeValue;
                }
                nodes.push(React.createElement(childNode.nodeName, attributes, domNodeChildrenToReactElements(childNode)));
            }
            else if (childNode.nodeName == "br") {
                nodes.push(React.createElement("br", null));
            }
        }
    }
    return nodes;
}
class InstructionStep extends React.Component {
    render() {
        let step = this.props.step;
        let stepIndex = this.props.stepIndex;
        let listKey = this.props.listKey;
        return React.createElement("article", { className: "text-col" },
            React.createElement("b", null,
                "Step ",
                stepIndex,
                ". "),
            renderDescription(step.description));
    }
}
exports.InstructionStep = InstructionStep;
class BomList extends React.Component {
    render() {
        var proj = this.props.proj;
        var snodes = [];
        var roots = proj.getRootBricks();
        if (roots.length > 0) {
            var root = proj.getBrickByName(roots[0]);
            var bom = root.getBom(proj, true);
            //Loop over parts
            var key = "mainbom_";
            var curstep = 1;
            for (let partid of bom.bom.keys()) {
                var quantity = bom.bom.get(partid);
                var part = proj.getPartByName(partid);
                var stepkey = key + curstep;
                curstep++;
                snodes.push(React.createElement("tr", { key: stepkey },
                    React.createElement("td", null,
                        React.createElement("a", { href: "#part_" + part.id }, part.name)),
                    React.createElement("td", null, quantity),
                    React.createElement("td", null, part.supplier),
                    React.createElement("td", null, part.supplier_part_num),
                    React.createElement("td", null, formatURL(part.url))));
            }
        }
        else {
            return React.createElement("div", null);
        }
        return React.createElement("div", { key: key + "_main" },
            React.createElement("table", null,
                React.createElement("thead", null,
                    React.createElement("tr", null,
                        React.createElement("th", null, "Part"),
                        React.createElement("th", null, "Quantity"),
                        React.createElement("th", null, "Supplier"),
                        React.createElement("th", null, "Supplier part number"),
                        React.createElement("th", null, "URL"))),
                React.createElement("tbody", null, snodes)));
    }
}
exports.BomList = BomList;
var urlcount = 1;
var formatURL = function (url) {
    urlcount = urlcount + 1;
    var ret = [];
    if (url != "") {
        var s = new String(url);
        s = s.replace(/.+\:\/\//gi, "");
        s = s.replace(/\/.*/gi, "");
        ret.push(React.createElement("a", { key: "url_" + urlcount + "_" + url, href: url }, s.toString()));
    }
    return ret;
};
var formatURLfile = function (url, filename) {
    urlcount = urlcount + 1;
    var ret = [];
    if (url != "") {
        ret.push(React.createElement("p", { key: "url_" + urlcount + "_" + url },
            React.createElement("a", { href: url },
                React.createElement("b", null,
                    "File: ",
                    filename))));
    }
    return ret;
};
var getQueryStringValue = function (key) {
    return decodeURIComponent(window.location.search.replace(new RegExp("^(?:.*[&\\?]" + encodeURIComponent(key).
        replace(/[\.\+\*]/g, "\\$&") + "(?:\\=([^&]*))?)?.*$", "i"), "$1"));
};
class Files extends React.Component {
    render() {
        var proj = this.props.proj;
        var files = this.props.files;
        function isImage(url) {
            return (url.toLowerCase().match(/\.(jpeg|jpg|gif|png|svg)$/) != null);
        }
        var projectid = getQueryStringValue("id");
        var basedir = proj.base_url;
        //var downloadlink="DownloadZip?id="+projectid;
        //Collect the files and images
        var inodes = [];
        var fnodes = [];
        for (let f of files) {
            var imgurl = basedir + f.url.replace(/\.\//g, '');
            if (isImage(imgurl)) {
                inodes.push(React.createElement("a", { key: this.props.basekey + f.url, href: imgurl, "data-lightbox": "image" },
                    React.createElement("img", { className: "instr-img", src: imgurl }),
                    React.createElement("p", { className: "instr-img-caption no-print" }, "Expand")));
            }
            else {
                var s = new String(f.url);
                s = s.replace(/.*\//gi, "");
                fnodes.push(formatURLfile(imgurl, s.toString())[0]);
            }
        }
        return React.createElement("div", null,
            fnodes,
            inodes);
    }
}
exports.Files = Files;


/***/ }),
/* 4 */
/***/ (function(module, exports, __webpack_require__) {

var __WEBPACK_AMD_DEFINE_FACTORY__, __WEBPACK_AMD_DEFINE_ARRAY__, __WEBPACK_AMD_DEFINE_RESULT__;// Browser Request
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// UMD HEADER START 
(function (root, factory) {
    if (true) {
        // AMD. Register as an anonymous module.
        !(__WEBPACK_AMD_DEFINE_ARRAY__ = [], __WEBPACK_AMD_DEFINE_FACTORY__ = (factory),
				__WEBPACK_AMD_DEFINE_RESULT__ = (typeof __WEBPACK_AMD_DEFINE_FACTORY__ === 'function' ?
				(__WEBPACK_AMD_DEFINE_FACTORY__.apply(exports, __WEBPACK_AMD_DEFINE_ARRAY__)) : __WEBPACK_AMD_DEFINE_FACTORY__),
				__WEBPACK_AMD_DEFINE_RESULT__ !== undefined && (module.exports = __WEBPACK_AMD_DEFINE_RESULT__));
    } else if (typeof exports === 'object') {
        // Node. Does not work with strict CommonJS, but
        // only CommonJS-like enviroments that support module.exports,
        // like Node.
        module.exports = factory();
    } else {
        // Browser globals (root is window)
        root.returnExports = factory();
  }
}(this, function () {
// UMD HEADER END

var XHR = XMLHttpRequest
if (!XHR) throw new Error('missing XMLHttpRequest')
request.log = {
  'trace': noop, 'debug': noop, 'info': noop, 'warn': noop, 'error': noop
}

var DEFAULT_TIMEOUT = 3 * 60 * 1000 // 3 minutes

//
// request
//

function request(options, callback) {
  // The entry-point to the API: prep the options object and pass the real work to run_xhr.
  if(typeof callback !== 'function')
    throw new Error('Bad callback given: ' + callback)

  if(!options)
    throw new Error('No options given')

  var options_onResponse = options.onResponse; // Save this for later.

  if(typeof options === 'string')
    options = {'uri':options};
  else
    options = JSON.parse(JSON.stringify(options)); // Use a duplicate for mutating.

  options.onResponse = options_onResponse // And put it back.

  if (options.verbose) request.log = getLogger();

  if(options.url) {
    options.uri = options.url;
    delete options.url;
  }

  if(!options.uri && options.uri !== "")
    throw new Error("options.uri is a required argument");

  if(typeof options.uri != "string")
    throw new Error("options.uri must be a string");

  var unsupported_options = ['proxy', '_redirectsFollowed', 'maxRedirects', 'followRedirect']
  for (var i = 0; i < unsupported_options.length; i++)
    if(options[ unsupported_options[i] ])
      throw new Error("options." + unsupported_options[i] + " is not supported")

  options.callback = callback
  options.method = options.method || 'GET';
  options.headers = options.headers || {};
  options.body    = options.body || null
  options.timeout = options.timeout || request.DEFAULT_TIMEOUT

  if(options.headers.host)
    throw new Error("Options.headers.host is not supported");

  if(options.json) {
    options.headers.accept = options.headers.accept || 'application/json'
    if(options.method !== 'GET')
      options.headers['content-type'] = 'application/json'

    if(typeof options.json !== 'boolean')
      options.body = JSON.stringify(options.json)
    else if(typeof options.body !== 'string')
      options.body = JSON.stringify(options.body)
  }
  
  //BEGIN QS Hack
  var serialize = function(obj) {
    var str = [];
    for(var p in obj)
      if (obj.hasOwnProperty(p)) {
        str.push(encodeURIComponent(p) + "=" + encodeURIComponent(obj[p]));
      }
    return str.join("&");
  }
  
  if(options.qs){
    var qs = (typeof options.qs == 'string')? options.qs : serialize(options.qs);
    if(options.uri.indexOf('?') !== -1){ //no get params
        options.uri = options.uri+'&'+qs;
    }else{ //existing get params
        options.uri = options.uri+'?'+qs;
    }
  }
  //END QS Hack
  
  //BEGIN FORM Hack
  var multipart = function(obj) {
    //todo: support file type (useful?)
    var result = {};
    result.boundry = '-------------------------------'+Math.floor(Math.random()*1000000000);
    var lines = [];
    for(var p in obj){
        if (obj.hasOwnProperty(p)) {
            lines.push(
                '--'+result.boundry+"\n"+
                'Content-Disposition: form-data; name="'+p+'"'+"\n"+
                "\n"+
                obj[p]+"\n"
            );
        }
    }
    lines.push( '--'+result.boundry+'--' );
    result.body = lines.join('');
    result.length = result.body.length;
    result.type = 'multipart/form-data; boundary='+result.boundry;
    return result;
  }
  
  if(options.form){
    if(typeof options.form == 'string') throw('form name unsupported');
    if(options.method === 'POST'){
        var encoding = (options.encoding || 'application/x-www-form-urlencoded').toLowerCase();
        options.headers['content-type'] = encoding;
        switch(encoding){
            case 'application/x-www-form-urlencoded':
                options.body = serialize(options.form).replace(/%20/g, "+");
                break;
            case 'multipart/form-data':
                var multi = multipart(options.form);
                //options.headers['content-length'] = multi.length;
                options.body = multi.body;
                options.headers['content-type'] = multi.type;
                break;
            default : throw new Error('unsupported encoding:'+encoding);
        }
    }
  }
  //END FORM Hack

  // If onResponse is boolean true, call back immediately when the response is known,
  // not when the full request is complete.
  options.onResponse = options.onResponse || noop
  if(options.onResponse === true) {
    options.onResponse = callback
    options.callback = noop
  }

  // XXX Browsers do not like this.
  //if(options.body)
  //  options.headers['content-length'] = options.body.length;

  // HTTP basic authentication
  if(!options.headers.authorization && options.auth)
    options.headers.authorization = 'Basic ' + b64_enc(options.auth.username + ':' + options.auth.password);

  return run_xhr(options)
}

var req_seq = 0
function run_xhr(options) {
  var xhr = new XHR
    , timed_out = false
    , is_cors = is_crossDomain(options.uri)
    , supports_cors = ('withCredentials' in xhr)

  req_seq += 1
  xhr.seq_id = req_seq
  xhr.id = req_seq + ': ' + options.method + ' ' + options.uri
  xhr._id = xhr.id // I know I will type "_id" from habit all the time.

  if(is_cors && !supports_cors) {
    var cors_err = new Error('Browser does not support cross-origin request: ' + options.uri)
    cors_err.cors = 'unsupported'
    return options.callback(cors_err, xhr)
  }

  xhr.timeoutTimer = setTimeout(too_late, options.timeout)
  function too_late() {
    timed_out = true
    var er = new Error('ETIMEDOUT')
    er.code = 'ETIMEDOUT'
    er.duration = options.timeout

    request.log.error('Timeout', { 'id':xhr._id, 'milliseconds':options.timeout })
    return options.callback(er, xhr)
  }

  // Some states can be skipped over, so remember what is still incomplete.
  var did = {'response':false, 'loading':false, 'end':false}

  xhr.onreadystatechange = on_state_change
  xhr.open(options.method, options.uri, true) // asynchronous
  if(is_cors)
    xhr.withCredentials = !! options.withCredentials
  xhr.send(options.body)
  return xhr

  function on_state_change(event) {
    if(timed_out)
      return request.log.debug('Ignoring timed out state change', {'state':xhr.readyState, 'id':xhr.id})

    request.log.debug('State change', {'state':xhr.readyState, 'id':xhr.id, 'timed_out':timed_out})

    if(xhr.readyState === XHR.OPENED) {
      request.log.debug('Request started', {'id':xhr.id})
      for (var key in options.headers)
        xhr.setRequestHeader(key, options.headers[key])
    }

    else if(xhr.readyState === XHR.HEADERS_RECEIVED)
      on_response()

    else if(xhr.readyState === XHR.LOADING) {
      on_response()
      on_loading()
    }

    else if(xhr.readyState === XHR.DONE) {
      on_response()
      on_loading()
      on_end()
    }
  }

  function on_response() {
    if(did.response)
      return

    did.response = true
    request.log.debug('Got response', {'id':xhr.id, 'status':xhr.status})
    clearTimeout(xhr.timeoutTimer)
    xhr.statusCode = xhr.status // Node request compatibility

    // Detect failed CORS requests.
    if(is_cors && xhr.statusCode == 0) {
      var cors_err = new Error('CORS request rejected: ' + options.uri)
      cors_err.cors = 'rejected'

      // Do not process this request further.
      did.loading = true
      did.end = true

      return options.callback(cors_err, xhr)
    }

    options.onResponse(null, xhr)
  }

  function on_loading() {
    if(did.loading)
      return

    did.loading = true
    request.log.debug('Response body loading', {'id':xhr.id})
    // TODO: Maybe simulate "data" events by watching xhr.responseText
  }

  function on_end() {
    if(did.end)
      return

    did.end = true
    request.log.debug('Request done', {'id':xhr.id})

    xhr.body = xhr.responseText
    if(options.json) {
      try        { xhr.body = JSON.parse(xhr.responseText) }
      catch (er) { return options.callback(er, xhr)        }
    }

    options.callback(null, xhr, xhr.body)
  }

} // request

request.withCredentials = false;
request.DEFAULT_TIMEOUT = DEFAULT_TIMEOUT;

//
// defaults
//

request.defaults = function(options, requester) {
  var def = function (method) {
    var d = function (params, callback) {
      if(typeof params === 'string')
        params = {'uri': params};
      else {
        params = JSON.parse(JSON.stringify(params));
      }
      for (var i in options) {
        if (params[i] === undefined) params[i] = options[i]
      }
      return method(params, callback)
    }
    return d
  }
  var de = def(request)
  de.get = def(request.get)
  de.post = def(request.post)
  de.put = def(request.put)
  de.head = def(request.head)
  return de
}

//
// HTTP method shortcuts
//

var shortcuts = [ 'get', 'put', 'post', 'head' ];
shortcuts.forEach(function(shortcut) {
  var method = shortcut.toUpperCase();
  var func   = shortcut.toLowerCase();

  request[func] = function(opts) {
    if(typeof opts === 'string')
      opts = {'method':method, 'uri':opts};
    else {
      opts = JSON.parse(JSON.stringify(opts));
      opts.method = method;
    }

    var args = [opts].concat(Array.prototype.slice.apply(arguments, [1]));
    return request.apply(this, args);
  }
})

//
// CouchDB shortcut
//

request.couch = function(options, callback) {
  if(typeof options === 'string')
    options = {'uri':options}

  // Just use the request API to do JSON.
  options.json = true
  if(options.body)
    options.json = options.body
  delete options.body

  callback = callback || noop

  var xhr = request(options, couch_handler)
  return xhr

  function couch_handler(er, resp, body) {
    if(er)
      return callback(er, resp, body)

    if((resp.statusCode < 200 || resp.statusCode > 299) && body.error) {
      // The body is a Couch JSON object indicating the error.
      er = new Error('CouchDB error: ' + (body.error.reason || body.error.error))
      for (var key in body)
        er[key] = body[key]
      return callback(er, resp, body);
    }

    return callback(er, resp, body);
  }
}

//
// Utility
//

function noop() {}

function getLogger() {
  var logger = {}
    , levels = ['trace', 'debug', 'info', 'warn', 'error']
    , level, i

  for(i = 0; i < levels.length; i++) {
    level = levels[i]

    logger[level] = noop
    if(typeof console !== 'undefined' && console && console[level])
      logger[level] = formatted(console, level)
  }

  return logger
}

function formatted(obj, method) {
  return formatted_logger

  function formatted_logger(str, context) {
    if(typeof context === 'object')
      str += ' ' + JSON.stringify(context)

    return obj[method].call(obj, str)
  }
}

// Return whether a URL is a cross-domain request.
function is_crossDomain(url) {
  var rurl = /^([\w\+\.\-]+:)(?:\/\/([^\/?#:]*)(?::(\d+))?)?/

  // jQuery #8138, IE may throw an exception when accessing
  // a field from window.location if document.domain has been set
  var ajaxLocation
  try { ajaxLocation = location.href }
  catch (e) {
    // Use the href attribute of an A element since IE will modify it given document.location
    ajaxLocation = document.createElement( "a" );
    ajaxLocation.href = "";
    ajaxLocation = ajaxLocation.href;
  }

  var ajaxLocParts = rurl.exec(ajaxLocation.toLowerCase()) || []
    , parts = rurl.exec(url.toLowerCase() )

  var result = !!(
    parts &&
    (  parts[1] != ajaxLocParts[1]
    || parts[2] != ajaxLocParts[2]
    || (parts[3] || (parts[1] === "http:" ? 80 : 443)) != (ajaxLocParts[3] || (ajaxLocParts[1] === "http:" ? 80 : 443))
    )
  )

  //console.debug('is_crossDomain('+url+') -> ' + result)
  return result
}

// MIT License from http://phpjs.org/functions/base64_encode:358
function b64_enc (data) {
    // Encodes string using MIME base64 algorithm
    var b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    var o1, o2, o3, h1, h2, h3, h4, bits, i = 0, ac = 0, enc="", tmp_arr = [];

    if (!data) {
        return data;
    }

    // assume utf8 data
    // data = this.utf8_encode(data+'');

    do { // pack three octets into four hexets
        o1 = data.charCodeAt(i++);
        o2 = data.charCodeAt(i++);
        o3 = data.charCodeAt(i++);

        bits = o1<<16 | o2<<8 | o3;

        h1 = bits>>18 & 0x3f;
        h2 = bits>>12 & 0x3f;
        h3 = bits>>6 & 0x3f;
        h4 = bits & 0x3f;

        // use hexets to index into b64, and append result to encoded string
        tmp_arr[ac++] = b64.charAt(h1) + b64.charAt(h2) + b64.charAt(h3) + b64.charAt(h4);
    } while (i < data.length);

    enc = tmp_arr.join('');

    switch (data.length % 3) {
        case 1:
            enc = enc.slice(0, -2) + '==';
        break;
        case 2:
            enc = enc.slice(0, -1) + '=';
        break;
    }

    return enc;
}
    return request;
//UMD FOOTER START
}));
//UMD FOOTER END


/***/ }),
/* 5 */
/***/ (function(module, exports) {

module.exports = ReactDOM;

/***/ }),
/* 6 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/* WEBPACK VAR INJECTION */(function(global) {

// compare and isBuffer taken from https://github.com/feross/buffer/blob/680e9e5e488f22aac27599a57dc844a6315928dd/index.js
// original notice:

/*!
 * The buffer module from node.js, for the browser.
 *
 * @author   Feross Aboukhadijeh <feross@feross.org> <http://feross.org>
 * @license  MIT
 */
function compare(a, b) {
  if (a === b) {
    return 0;
  }

  var x = a.length;
  var y = b.length;

  for (var i = 0, len = Math.min(x, y); i < len; ++i) {
    if (a[i] !== b[i]) {
      x = a[i];
      y = b[i];
      break;
    }
  }

  if (x < y) {
    return -1;
  }
  if (y < x) {
    return 1;
  }
  return 0;
}
function isBuffer(b) {
  if (global.Buffer && typeof global.Buffer.isBuffer === 'function') {
    return global.Buffer.isBuffer(b);
  }
  return !!(b != null && b._isBuffer);
}

// based on node assert, original notice:

// http://wiki.commonjs.org/wiki/Unit_Testing/1.0
//
// THIS IS NOT TESTED NOR LIKELY TO WORK OUTSIDE V8!
//
// Originally from narwhal.js (http://narwhaljs.org)
// Copyright (c) 2009 Thomas Robinson <280north.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the 'Software'), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

var util = __webpack_require__(11);
var hasOwn = Object.prototype.hasOwnProperty;
var pSlice = Array.prototype.slice;
var functionsHaveNames = (function () {
  return function foo() {}.name === 'foo';
}());
function pToString (obj) {
  return Object.prototype.toString.call(obj);
}
function isView(arrbuf) {
  if (isBuffer(arrbuf)) {
    return false;
  }
  if (typeof global.ArrayBuffer !== 'function') {
    return false;
  }
  if (typeof ArrayBuffer.isView === 'function') {
    return ArrayBuffer.isView(arrbuf);
  }
  if (!arrbuf) {
    return false;
  }
  if (arrbuf instanceof DataView) {
    return true;
  }
  if (arrbuf.buffer && arrbuf.buffer instanceof ArrayBuffer) {
    return true;
  }
  return false;
}
// 1. The assert module provides functions that throw
// AssertionError's when particular conditions are not met. The
// assert module must conform to the following interface.

var assert = module.exports = ok;

// 2. The AssertionError is defined in assert.
// new assert.AssertionError({ message: message,
//                             actual: actual,
//                             expected: expected })

var regex = /\s*function\s+([^\(\s]*)\s*/;
// based on https://github.com/ljharb/function.prototype.name/blob/adeeeec8bfcc6068b187d7d9fb3d5bb1d3a30899/implementation.js
function getName(func) {
  if (!util.isFunction(func)) {
    return;
  }
  if (functionsHaveNames) {
    return func.name;
  }
  var str = func.toString();
  var match = str.match(regex);
  return match && match[1];
}
assert.AssertionError = function AssertionError(options) {
  this.name = 'AssertionError';
  this.actual = options.actual;
  this.expected = options.expected;
  this.operator = options.operator;
  if (options.message) {
    this.message = options.message;
    this.generatedMessage = false;
  } else {
    this.message = getMessage(this);
    this.generatedMessage = true;
  }
  var stackStartFunction = options.stackStartFunction || fail;
  if (Error.captureStackTrace) {
    Error.captureStackTrace(this, stackStartFunction);
  } else {
    // non v8 browsers so we can have a stacktrace
    var err = new Error();
    if (err.stack) {
      var out = err.stack;

      // try to strip useless frames
      var fn_name = getName(stackStartFunction);
      var idx = out.indexOf('\n' + fn_name);
      if (idx >= 0) {
        // once we have located the function frame
        // we need to strip out everything before it (and its line)
        var next_line = out.indexOf('\n', idx + 1);
        out = out.substring(next_line + 1);
      }

      this.stack = out;
    }
  }
};

// assert.AssertionError instanceof Error
util.inherits(assert.AssertionError, Error);

function truncate(s, n) {
  if (typeof s === 'string') {
    return s.length < n ? s : s.slice(0, n);
  } else {
    return s;
  }
}
function inspect(something) {
  if (functionsHaveNames || !util.isFunction(something)) {
    return util.inspect(something);
  }
  var rawname = getName(something);
  var name = rawname ? ': ' + rawname : '';
  return '[Function' +  name + ']';
}
function getMessage(self) {
  return truncate(inspect(self.actual), 128) + ' ' +
         self.operator + ' ' +
         truncate(inspect(self.expected), 128);
}

// At present only the three keys mentioned above are used and
// understood by the spec. Implementations or sub modules can pass
// other keys to the AssertionError's constructor - they will be
// ignored.

// 3. All of the following functions must throw an AssertionError
// when a corresponding condition is not met, with a message that
// may be undefined if not provided.  All assertion methods provide
// both the actual and expected values to the assertion error for
// display purposes.

function fail(actual, expected, message, operator, stackStartFunction) {
  throw new assert.AssertionError({
    message: message,
    actual: actual,
    expected: expected,
    operator: operator,
    stackStartFunction: stackStartFunction
  });
}

// EXTENSION! allows for well behaved errors defined elsewhere.
assert.fail = fail;

// 4. Pure assertion tests whether a value is truthy, as determined
// by !!guard.
// assert.ok(guard, message_opt);
// This statement is equivalent to assert.equal(true, !!guard,
// message_opt);. To test strictly for the value true, use
// assert.strictEqual(true, guard, message_opt);.

function ok(value, message) {
  if (!value) fail(value, true, message, '==', assert.ok);
}
assert.ok = ok;

// 5. The equality assertion tests shallow, coercive equality with
// ==.
// assert.equal(actual, expected, message_opt);

assert.equal = function equal(actual, expected, message) {
  if (actual != expected) fail(actual, expected, message, '==', assert.equal);
};

// 6. The non-equality assertion tests for whether two objects are not equal
// with != assert.notEqual(actual, expected, message_opt);

assert.notEqual = function notEqual(actual, expected, message) {
  if (actual == expected) {
    fail(actual, expected, message, '!=', assert.notEqual);
  }
};

// 7. The equivalence assertion tests a deep equality relation.
// assert.deepEqual(actual, expected, message_opt);

assert.deepEqual = function deepEqual(actual, expected, message) {
  if (!_deepEqual(actual, expected, false)) {
    fail(actual, expected, message, 'deepEqual', assert.deepEqual);
  }
};

assert.deepStrictEqual = function deepStrictEqual(actual, expected, message) {
  if (!_deepEqual(actual, expected, true)) {
    fail(actual, expected, message, 'deepStrictEqual', assert.deepStrictEqual);
  }
};

function _deepEqual(actual, expected, strict, memos) {
  // 7.1. All identical values are equivalent, as determined by ===.
  if (actual === expected) {
    return true;
  } else if (isBuffer(actual) && isBuffer(expected)) {
    return compare(actual, expected) === 0;

  // 7.2. If the expected value is a Date object, the actual value is
  // equivalent if it is also a Date object that refers to the same time.
  } else if (util.isDate(actual) && util.isDate(expected)) {
    return actual.getTime() === expected.getTime();

  // 7.3 If the expected value is a RegExp object, the actual value is
  // equivalent if it is also a RegExp object with the same source and
  // properties (`global`, `multiline`, `lastIndex`, `ignoreCase`).
  } else if (util.isRegExp(actual) && util.isRegExp(expected)) {
    return actual.source === expected.source &&
           actual.global === expected.global &&
           actual.multiline === expected.multiline &&
           actual.lastIndex === expected.lastIndex &&
           actual.ignoreCase === expected.ignoreCase;

  // 7.4. Other pairs that do not both pass typeof value == 'object',
  // equivalence is determined by ==.
  } else if ((actual === null || typeof actual !== 'object') &&
             (expected === null || typeof expected !== 'object')) {
    return strict ? actual === expected : actual == expected;

  // If both values are instances of typed arrays, wrap their underlying
  // ArrayBuffers in a Buffer each to increase performance
  // This optimization requires the arrays to have the same type as checked by
  // Object.prototype.toString (aka pToString). Never perform binary
  // comparisons for Float*Arrays, though, since e.g. +0 === -0 but their
  // bit patterns are not identical.
  } else if (isView(actual) && isView(expected) &&
             pToString(actual) === pToString(expected) &&
             !(actual instanceof Float32Array ||
               actual instanceof Float64Array)) {
    return compare(new Uint8Array(actual.buffer),
                   new Uint8Array(expected.buffer)) === 0;

  // 7.5 For all other Object pairs, including Array objects, equivalence is
  // determined by having the same number of owned properties (as verified
  // with Object.prototype.hasOwnProperty.call), the same set of keys
  // (although not necessarily the same order), equivalent values for every
  // corresponding key, and an identical 'prototype' property. Note: this
  // accounts for both named and indexed properties on Arrays.
  } else if (isBuffer(actual) !== isBuffer(expected)) {
    return false;
  } else {
    memos = memos || {actual: [], expected: []};

    var actualIndex = memos.actual.indexOf(actual);
    if (actualIndex !== -1) {
      if (actualIndex === memos.expected.indexOf(expected)) {
        return true;
      }
    }

    memos.actual.push(actual);
    memos.expected.push(expected);

    return objEquiv(actual, expected, strict, memos);
  }
}

function isArguments(object) {
  return Object.prototype.toString.call(object) == '[object Arguments]';
}

function objEquiv(a, b, strict, actualVisitedObjects) {
  if (a === null || a === undefined || b === null || b === undefined)
    return false;
  // if one is a primitive, the other must be same
  if (util.isPrimitive(a) || util.isPrimitive(b))
    return a === b;
  if (strict && Object.getPrototypeOf(a) !== Object.getPrototypeOf(b))
    return false;
  var aIsArgs = isArguments(a);
  var bIsArgs = isArguments(b);
  if ((aIsArgs && !bIsArgs) || (!aIsArgs && bIsArgs))
    return false;
  if (aIsArgs) {
    a = pSlice.call(a);
    b = pSlice.call(b);
    return _deepEqual(a, b, strict);
  }
  var ka = objectKeys(a);
  var kb = objectKeys(b);
  var key, i;
  // having the same number of owned properties (keys incorporates
  // hasOwnProperty)
  if (ka.length !== kb.length)
    return false;
  //the same set of keys (although not necessarily the same order),
  ka.sort();
  kb.sort();
  //~~~cheap key test
  for (i = ka.length - 1; i >= 0; i--) {
    if (ka[i] !== kb[i])
      return false;
  }
  //equivalent values for every corresponding key, and
  //~~~possibly expensive deep test
  for (i = ka.length - 1; i >= 0; i--) {
    key = ka[i];
    if (!_deepEqual(a[key], b[key], strict, actualVisitedObjects))
      return false;
  }
  return true;
}

// 8. The non-equivalence assertion tests for any deep inequality.
// assert.notDeepEqual(actual, expected, message_opt);

assert.notDeepEqual = function notDeepEqual(actual, expected, message) {
  if (_deepEqual(actual, expected, false)) {
    fail(actual, expected, message, 'notDeepEqual', assert.notDeepEqual);
  }
};

assert.notDeepStrictEqual = notDeepStrictEqual;
function notDeepStrictEqual(actual, expected, message) {
  if (_deepEqual(actual, expected, true)) {
    fail(actual, expected, message, 'notDeepStrictEqual', notDeepStrictEqual);
  }
}


// 9. The strict equality assertion tests strict equality, as determined by ===.
// assert.strictEqual(actual, expected, message_opt);

assert.strictEqual = function strictEqual(actual, expected, message) {
  if (actual !== expected) {
    fail(actual, expected, message, '===', assert.strictEqual);
  }
};

// 10. The strict non-equality assertion tests for strict inequality, as
// determined by !==.  assert.notStrictEqual(actual, expected, message_opt);

assert.notStrictEqual = function notStrictEqual(actual, expected, message) {
  if (actual === expected) {
    fail(actual, expected, message, '!==', assert.notStrictEqual);
  }
};

function expectedException(actual, expected) {
  if (!actual || !expected) {
    return false;
  }

  if (Object.prototype.toString.call(expected) == '[object RegExp]') {
    return expected.test(actual);
  }

  try {
    if (actual instanceof expected) {
      return true;
    }
  } catch (e) {
    // Ignore.  The instanceof check doesn't work for arrow functions.
  }

  if (Error.isPrototypeOf(expected)) {
    return false;
  }

  return expected.call({}, actual) === true;
}

function _tryBlock(block) {
  var error;
  try {
    block();
  } catch (e) {
    error = e;
  }
  return error;
}

function _throws(shouldThrow, block, expected, message) {
  var actual;

  if (typeof block !== 'function') {
    throw new TypeError('"block" argument must be a function');
  }

  if (typeof expected === 'string') {
    message = expected;
    expected = null;
  }

  actual = _tryBlock(block);

  message = (expected && expected.name ? ' (' + expected.name + ').' : '.') +
            (message ? ' ' + message : '.');

  if (shouldThrow && !actual) {
    fail(actual, expected, 'Missing expected exception' + message);
  }

  var userProvidedMessage = typeof message === 'string';
  var isUnwantedException = !shouldThrow && util.isError(actual);
  var isUnexpectedException = !shouldThrow && actual && !expected;

  if ((isUnwantedException &&
      userProvidedMessage &&
      expectedException(actual, expected)) ||
      isUnexpectedException) {
    fail(actual, expected, 'Got unwanted exception' + message);
  }

  if ((shouldThrow && actual && expected &&
      !expectedException(actual, expected)) || (!shouldThrow && actual)) {
    throw actual;
  }
}

// 11. Expected to throw an error:
// assert.throws(block, Error_opt, message_opt);

assert.throws = function(block, /*optional*/error, /*optional*/message) {
  _throws(true, block, error, message);
};

// EXTENSION! This is annoying to write outside this module.
assert.doesNotThrow = function(block, /*optional*/error, /*optional*/message) {
  _throws(false, block, error, message);
};

assert.ifError = function(err) { if (err) throw err; };

var objectKeys = Object.keys || function (obj) {
  var keys = [];
  for (var key in obj) {
    if (hasOwn.call(obj, key)) keys.push(key);
  }
  return keys;
};

/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(1)))

/***/ }),
/* 7 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
const React = __webpack_require__(0);
const ReactDOM = __webpack_require__(5);
const docubricksViewer_1 = __webpack_require__(3);
const Docubricks = __webpack_require__(2);
const request = __webpack_require__(4);
//alert(getQueryStringValue("id")); 
function getQueryVariable(variable) {
    // retrieve a query variable from the URL (used to specify the URL on the command line)
    // courtesy of CHRIS COYIER at https://css-tricks.com/snippets/javascript/get-url-variables/
    var query = window.location.search.substring(1);
    var vars = query.split("&");
    for (var i = 0; i < vars.length; i++) {
        var pair = vars[i].split("=");
        if (pair[0] == variable) {
            return pair[1];
        }
    }
    return (''); // we return an empty string rather than false to avoid type issues.
    // NB empty string will evaluate to false if cast to boolean.
}
if (document.getElementById("hiddendata")) {
    // the XML has been converted to JSON and base64 encoded in the HTML document.
    // we assume the supporting files are in ./project/ (the default base_url defined in docubricks.ts)
    var s = document.getElementById("hiddendata").textContent;
    document.getElementById("hiddendata").textContent = "";
    var docu = Docubricks.docubricksFromJSON(s);
    ReactDOM.render(React.createElement(docubricksViewer_1.DocubricksProject, { proj: docu }), document.getElementById("example"));
}
if (document.getElementById("docubricks_xml_url")) {
    // We use an HTTP request to retrieve the XML from a URL, which works well for e.g. GitHub.
    var url = document.getElementById("docubricks_xml_url").textContent;
    document.getElementById("docubricks_xml_url").textContent = "";
    if (url == "docubricks_xml_url will be read from the query string.") {
        url = decodeURIComponent(getQueryVariable("docubricks_xml_url"));
    }
    var base_url = url.split('/').slice(0, -1).join('/') + '/'; // the DocuBricks root folder
    // paths for images and other files in the DocuBricks project should be given relative to the docubricks root folder
    request(url, function (error, response, body) {
        console.log('statusCode retrieving XML file:', response && response.statusCode);
        console.log('error:', error);
        Docubricks.docubricksFromXML(body, function (docu) {
            docu.base_url = base_url;
            ReactDOM.render(React.createElement(docubricksViewer_1.DocubricksProject, { proj: docu }), document.getElementById("example"));
        });
    });
}
if (document.getElementById("docubricks_xml")) {
    var xmlstring = document.getElementById("docubricks_xml").textContent;
    //document.getElementById("docubricks_xml").textContent="";
    console.log("XML String");
    console.log(xmlstring);
    Docubricks.docubricksFromXML(xmlstring, function (docu) {
        ReactDOM.render(React.createElement(docubricksViewer_1.DocubricksProject, { proj: docu }), document.getElementById("example"));
    });
}
if (document.getElementById("docubricks_xml_iframe")) {
    console.log("Loading from iframe");
    let iframe = document.getElementById("docubricks_xml_iframe");
    let xmldoc = iframe.contentDocument || iframe.contentWindow.document;
    console.log(xmldoc);
    let docu = Docubricks.docubricksFromDOM(xmldoc);
    ReactDOM.render(React.createElement(docubricksViewer_1.DocubricksProject, { proj: docu }), document.getElementById("example"));
}
function loadDocumentFromFileInput() {
    var fileinput = document.getElementById("docubricks_xml_file_input");
    console.log("Loading file from file input control.");
    if ("files" in fileinput) {
        if (fileinput.files.length > 0) {
            let file = fileinput.files[0];
            console.log("Reading file: " + file.name);
            let reader = new FileReader();
            reader.onload = function () {
                let docu = Docubricks.docubricksFromXMLSync(reader.result);
                ReactDOM.render(React.createElement(docubricksViewer_1.DocubricksProject, { proj: docu }), document.getElementById("example"));
            };
            reader.readAsText(file);
        }
    }
}


/***/ }),
/* 8 */
/***/ (function(module, exports) {

// shim for using process in browser
var process = module.exports = {};

// cached from whatever global is present so that test runners that stub it
// don't break things.  But we need to wrap it in a try catch in case it is
// wrapped in strict mode code which doesn't define any globals.  It's inside a
// function because try/catches deoptimize in certain engines.

var cachedSetTimeout;
var cachedClearTimeout;

function defaultSetTimout() {
    throw new Error('setTimeout has not been defined');
}
function defaultClearTimeout () {
    throw new Error('clearTimeout has not been defined');
}
(function () {
    try {
        if (typeof setTimeout === 'function') {
            cachedSetTimeout = setTimeout;
        } else {
            cachedSetTimeout = defaultSetTimout;
        }
    } catch (e) {
        cachedSetTimeout = defaultSetTimout;
    }
    try {
        if (typeof clearTimeout === 'function') {
            cachedClearTimeout = clearTimeout;
        } else {
            cachedClearTimeout = defaultClearTimeout;
        }
    } catch (e) {
        cachedClearTimeout = defaultClearTimeout;
    }
} ())
function runTimeout(fun) {
    if (cachedSetTimeout === setTimeout) {
        //normal enviroments in sane situations
        return setTimeout(fun, 0);
    }
    // if setTimeout wasn't available but was latter defined
    if ((cachedSetTimeout === defaultSetTimout || !cachedSetTimeout) && setTimeout) {
        cachedSetTimeout = setTimeout;
        return setTimeout(fun, 0);
    }
    try {
        // when when somebody has screwed with setTimeout but no I.E. maddness
        return cachedSetTimeout(fun, 0);
    } catch(e){
        try {
            // When we are in I.E. but the script has been evaled so I.E. doesn't trust the global object when called normally
            return cachedSetTimeout.call(null, fun, 0);
        } catch(e){
            // same as above but when it's a version of I.E. that must have the global object for 'this', hopfully our context correct otherwise it will throw a global error
            return cachedSetTimeout.call(this, fun, 0);
        }
    }


}
function runClearTimeout(marker) {
    if (cachedClearTimeout === clearTimeout) {
        //normal enviroments in sane situations
        return clearTimeout(marker);
    }
    // if clearTimeout wasn't available but was latter defined
    if ((cachedClearTimeout === defaultClearTimeout || !cachedClearTimeout) && clearTimeout) {
        cachedClearTimeout = clearTimeout;
        return clearTimeout(marker);
    }
    try {
        // when when somebody has screwed with setTimeout but no I.E. maddness
        return cachedClearTimeout(marker);
    } catch (e){
        try {
            // When we are in I.E. but the script has been evaled so I.E. doesn't  trust the global object when called normally
            return cachedClearTimeout.call(null, marker);
        } catch (e){
            // same as above but when it's a version of I.E. that must have the global object for 'this', hopfully our context correct otherwise it will throw a global error.
            // Some versions of I.E. have different rules for clearTimeout vs setTimeout
            return cachedClearTimeout.call(this, marker);
        }
    }



}
var queue = [];
var draining = false;
var currentQueue;
var queueIndex = -1;

function cleanUpNextTick() {
    if (!draining || !currentQueue) {
        return;
    }
    draining = false;
    if (currentQueue.length) {
        queue = currentQueue.concat(queue);
    } else {
        queueIndex = -1;
    }
    if (queue.length) {
        drainQueue();
    }
}

function drainQueue() {
    if (draining) {
        return;
    }
    var timeout = runTimeout(cleanUpNextTick);
    draining = true;

    var len = queue.length;
    while(len) {
        currentQueue = queue;
        queue = [];
        while (++queueIndex < len) {
            if (currentQueue) {
                currentQueue[queueIndex].run();
            }
        }
        queueIndex = -1;
        len = queue.length;
    }
    currentQueue = null;
    draining = false;
    runClearTimeout(timeout);
}

process.nextTick = function (fun) {
    var args = new Array(arguments.length - 1);
    if (arguments.length > 1) {
        for (var i = 1; i < arguments.length; i++) {
            args[i - 1] = arguments[i];
        }
    }
    queue.push(new Item(fun, args));
    if (queue.length === 1 && !draining) {
        runTimeout(drainQueue);
    }
};

// v8 likes predictible objects
function Item(fun, array) {
    this.fun = fun;
    this.array = array;
}
Item.prototype.run = function () {
    this.fun.apply(null, this.array);
};
process.title = 'browser';
process.browser = true;
process.env = {};
process.argv = [];
process.version = ''; // empty string to avoid regexp issues
process.versions = {};

function noop() {}

process.on = noop;
process.addListener = noop;
process.once = noop;
process.off = noop;
process.removeListener = noop;
process.removeAllListeners = noop;
process.emit = noop;
process.prependListener = noop;
process.prependOnceListener = noop;

process.listeners = function (name) { return [] }

process.binding = function (name) {
    throw new Error('process.binding is not supported');
};

process.cwd = function () { return '/' };
process.chdir = function (dir) {
    throw new Error('process.chdir is not supported');
};
process.umask = function() { return 0; };


/***/ }),
/* 9 */
/***/ (function(module, exports) {

if (typeof Object.create === 'function') {
  // implementation from standard node.js 'util' module
  module.exports = function inherits(ctor, superCtor) {
    ctor.super_ = superCtor
    ctor.prototype = Object.create(superCtor.prototype, {
      constructor: {
        value: ctor,
        enumerable: false,
        writable: true,
        configurable: true
      }
    });
  };
} else {
  // old school shim for old browsers
  module.exports = function inherits(ctor, superCtor) {
    ctor.super_ = superCtor
    var TempCtor = function () {}
    TempCtor.prototype = superCtor.prototype
    ctor.prototype = new TempCtor()
    ctor.prototype.constructor = ctor
  }
}


/***/ }),
/* 10 */
/***/ (function(module, exports) {

module.exports = function isBuffer(arg) {
  return arg && typeof arg === 'object'
    && typeof arg.copy === 'function'
    && typeof arg.fill === 'function'
    && typeof arg.readUInt8 === 'function';
}

/***/ }),
/* 11 */
/***/ (function(module, exports, __webpack_require__) {

/* WEBPACK VAR INJECTION */(function(global, process) {// Copyright Joyent, Inc. and other Node contributors.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.

var formatRegExp = /%[sdj%]/g;
exports.format = function(f) {
  if (!isString(f)) {
    var objects = [];
    for (var i = 0; i < arguments.length; i++) {
      objects.push(inspect(arguments[i]));
    }
    return objects.join(' ');
  }

  var i = 1;
  var args = arguments;
  var len = args.length;
  var str = String(f).replace(formatRegExp, function(x) {
    if (x === '%%') return '%';
    if (i >= len) return x;
    switch (x) {
      case '%s': return String(args[i++]);
      case '%d': return Number(args[i++]);
      case '%j':
        try {
          return JSON.stringify(args[i++]);
        } catch (_) {
          return '[Circular]';
        }
      default:
        return x;
    }
  });
  for (var x = args[i]; i < len; x = args[++i]) {
    if (isNull(x) || !isObject(x)) {
      str += ' ' + x;
    } else {
      str += ' ' + inspect(x);
    }
  }
  return str;
};


// Mark that a method should not be used.
// Returns a modified function which warns once by default.
// If --no-deprecation is set, then it is a no-op.
exports.deprecate = function(fn, msg) {
  // Allow for deprecating things in the process of starting up.
  if (isUndefined(global.process)) {
    return function() {
      return exports.deprecate(fn, msg).apply(this, arguments);
    };
  }

  if (process.noDeprecation === true) {
    return fn;
  }

  var warned = false;
  function deprecated() {
    if (!warned) {
      if (process.throwDeprecation) {
        throw new Error(msg);
      } else if (process.traceDeprecation) {
        console.trace(msg);
      } else {
        console.error(msg);
      }
      warned = true;
    }
    return fn.apply(this, arguments);
  }

  return deprecated;
};


var debugs = {};
var debugEnviron;
exports.debuglog = function(set) {
  if (isUndefined(debugEnviron))
    debugEnviron = process.env.NODE_DEBUG || '';
  set = set.toUpperCase();
  if (!debugs[set]) {
    if (new RegExp('\\b' + set + '\\b', 'i').test(debugEnviron)) {
      var pid = process.pid;
      debugs[set] = function() {
        var msg = exports.format.apply(exports, arguments);
        console.error('%s %d: %s', set, pid, msg);
      };
    } else {
      debugs[set] = function() {};
    }
  }
  return debugs[set];
};


/**
 * Echos the value of a value. Trys to print the value out
 * in the best way possible given the different types.
 *
 * @param {Object} obj The object to print out.
 * @param {Object} opts Optional options object that alters the output.
 */
/* legacy: obj, showHidden, depth, colors*/
function inspect(obj, opts) {
  // default options
  var ctx = {
    seen: [],
    stylize: stylizeNoColor
  };
  // legacy...
  if (arguments.length >= 3) ctx.depth = arguments[2];
  if (arguments.length >= 4) ctx.colors = arguments[3];
  if (isBoolean(opts)) {
    // legacy...
    ctx.showHidden = opts;
  } else if (opts) {
    // got an "options" object
    exports._extend(ctx, opts);
  }
  // set default options
  if (isUndefined(ctx.showHidden)) ctx.showHidden = false;
  if (isUndefined(ctx.depth)) ctx.depth = 2;
  if (isUndefined(ctx.colors)) ctx.colors = false;
  if (isUndefined(ctx.customInspect)) ctx.customInspect = true;
  if (ctx.colors) ctx.stylize = stylizeWithColor;
  return formatValue(ctx, obj, ctx.depth);
}
exports.inspect = inspect;


// http://en.wikipedia.org/wiki/ANSI_escape_code#graphics
inspect.colors = {
  'bold' : [1, 22],
  'italic' : [3, 23],
  'underline' : [4, 24],
  'inverse' : [7, 27],
  'white' : [37, 39],
  'grey' : [90, 39],
  'black' : [30, 39],
  'blue' : [34, 39],
  'cyan' : [36, 39],
  'green' : [32, 39],
  'magenta' : [35, 39],
  'red' : [31, 39],
  'yellow' : [33, 39]
};

// Don't use 'blue' not visible on cmd.exe
inspect.styles = {
  'special': 'cyan',
  'number': 'yellow',
  'boolean': 'yellow',
  'undefined': 'grey',
  'null': 'bold',
  'string': 'green',
  'date': 'magenta',
  // "name": intentionally not styling
  'regexp': 'red'
};


function stylizeWithColor(str, styleType) {
  var style = inspect.styles[styleType];

  if (style) {
    return '\u001b[' + inspect.colors[style][0] + 'm' + str +
           '\u001b[' + inspect.colors[style][1] + 'm';
  } else {
    return str;
  }
}


function stylizeNoColor(str, styleType) {
  return str;
}


function arrayToHash(array) {
  var hash = {};

  array.forEach(function(val, idx) {
    hash[val] = true;
  });

  return hash;
}


function formatValue(ctx, value, recurseTimes) {
  // Provide a hook for user-specified inspect functions.
  // Check that value is an object with an inspect function on it
  if (ctx.customInspect &&
      value &&
      isFunction(value.inspect) &&
      // Filter out the util module, it's inspect function is special
      value.inspect !== exports.inspect &&
      // Also filter out any prototype objects using the circular check.
      !(value.constructor && value.constructor.prototype === value)) {
    var ret = value.inspect(recurseTimes, ctx);
    if (!isString(ret)) {
      ret = formatValue(ctx, ret, recurseTimes);
    }
    return ret;
  }

  // Primitive types cannot have properties
  var primitive = formatPrimitive(ctx, value);
  if (primitive) {
    return primitive;
  }

  // Look up the keys of the object.
  var keys = Object.keys(value);
  var visibleKeys = arrayToHash(keys);

  if (ctx.showHidden) {
    keys = Object.getOwnPropertyNames(value);
  }

  // IE doesn't make error fields non-enumerable
  // http://msdn.microsoft.com/en-us/library/ie/dww52sbt(v=vs.94).aspx
  if (isError(value)
      && (keys.indexOf('message') >= 0 || keys.indexOf('description') >= 0)) {
    return formatError(value);
  }

  // Some type of object without properties can be shortcutted.
  if (keys.length === 0) {
    if (isFunction(value)) {
      var name = value.name ? ': ' + value.name : '';
      return ctx.stylize('[Function' + name + ']', 'special');
    }
    if (isRegExp(value)) {
      return ctx.stylize(RegExp.prototype.toString.call(value), 'regexp');
    }
    if (isDate(value)) {
      return ctx.stylize(Date.prototype.toString.call(value), 'date');
    }
    if (isError(value)) {
      return formatError(value);
    }
  }

  var base = '', array = false, braces = ['{', '}'];

  // Make Array say that they are Array
  if (isArray(value)) {
    array = true;
    braces = ['[', ']'];
  }

  // Make functions say that they are functions
  if (isFunction(value)) {
    var n = value.name ? ': ' + value.name : '';
    base = ' [Function' + n + ']';
  }

  // Make RegExps say that they are RegExps
  if (isRegExp(value)) {
    base = ' ' + RegExp.prototype.toString.call(value);
  }

  // Make dates with properties first say the date
  if (isDate(value)) {
    base = ' ' + Date.prototype.toUTCString.call(value);
  }

  // Make error with message first say the error
  if (isError(value)) {
    base = ' ' + formatError(value);
  }

  if (keys.length === 0 && (!array || value.length == 0)) {
    return braces[0] + base + braces[1];
  }

  if (recurseTimes < 0) {
    if (isRegExp(value)) {
      return ctx.stylize(RegExp.prototype.toString.call(value), 'regexp');
    } else {
      return ctx.stylize('[Object]', 'special');
    }
  }

  ctx.seen.push(value);

  var output;
  if (array) {
    output = formatArray(ctx, value, recurseTimes, visibleKeys, keys);
  } else {
    output = keys.map(function(key) {
      return formatProperty(ctx, value, recurseTimes, visibleKeys, key, array);
    });
  }

  ctx.seen.pop();

  return reduceToSingleString(output, base, braces);
}


function formatPrimitive(ctx, value) {
  if (isUndefined(value))
    return ctx.stylize('undefined', 'undefined');
  if (isString(value)) {
    var simple = '\'' + JSON.stringify(value).replace(/^"|"$/g, '')
                                             .replace(/'/g, "\\'")
                                             .replace(/\\"/g, '"') + '\'';
    return ctx.stylize(simple, 'string');
  }
  if (isNumber(value))
    return ctx.stylize('' + value, 'number');
  if (isBoolean(value))
    return ctx.stylize('' + value, 'boolean');
  // For some reason typeof null is "object", so special case here.
  if (isNull(value))
    return ctx.stylize('null', 'null');
}


function formatError(value) {
  return '[' + Error.prototype.toString.call(value) + ']';
}


function formatArray(ctx, value, recurseTimes, visibleKeys, keys) {
  var output = [];
  for (var i = 0, l = value.length; i < l; ++i) {
    if (hasOwnProperty(value, String(i))) {
      output.push(formatProperty(ctx, value, recurseTimes, visibleKeys,
          String(i), true));
    } else {
      output.push('');
    }
  }
  keys.forEach(function(key) {
    if (!key.match(/^\d+$/)) {
      output.push(formatProperty(ctx, value, recurseTimes, visibleKeys,
          key, true));
    }
  });
  return output;
}


function formatProperty(ctx, value, recurseTimes, visibleKeys, key, array) {
  var name, str, desc;
  desc = Object.getOwnPropertyDescriptor(value, key) || { value: value[key] };
  if (desc.get) {
    if (desc.set) {
      str = ctx.stylize('[Getter/Setter]', 'special');
    } else {
      str = ctx.stylize('[Getter]', 'special');
    }
  } else {
    if (desc.set) {
      str = ctx.stylize('[Setter]', 'special');
    }
  }
  if (!hasOwnProperty(visibleKeys, key)) {
    name = '[' + key + ']';
  }
  if (!str) {
    if (ctx.seen.indexOf(desc.value) < 0) {
      if (isNull(recurseTimes)) {
        str = formatValue(ctx, desc.value, null);
      } else {
        str = formatValue(ctx, desc.value, recurseTimes - 1);
      }
      if (str.indexOf('\n') > -1) {
        if (array) {
          str = str.split('\n').map(function(line) {
            return '  ' + line;
          }).join('\n').substr(2);
        } else {
          str = '\n' + str.split('\n').map(function(line) {
            return '   ' + line;
          }).join('\n');
        }
      }
    } else {
      str = ctx.stylize('[Circular]', 'special');
    }
  }
  if (isUndefined(name)) {
    if (array && key.match(/^\d+$/)) {
      return str;
    }
    name = JSON.stringify('' + key);
    if (name.match(/^"([a-zA-Z_][a-zA-Z_0-9]*)"$/)) {
      name = name.substr(1, name.length - 2);
      name = ctx.stylize(name, 'name');
    } else {
      name = name.replace(/'/g, "\\'")
                 .replace(/\\"/g, '"')
                 .replace(/(^"|"$)/g, "'");
      name = ctx.stylize(name, 'string');
    }
  }

  return name + ': ' + str;
}


function reduceToSingleString(output, base, braces) {
  var numLinesEst = 0;
  var length = output.reduce(function(prev, cur) {
    numLinesEst++;
    if (cur.indexOf('\n') >= 0) numLinesEst++;
    return prev + cur.replace(/\u001b\[\d\d?m/g, '').length + 1;
  }, 0);

  if (length > 60) {
    return braces[0] +
           (base === '' ? '' : base + '\n ') +
           ' ' +
           output.join(',\n  ') +
           ' ' +
           braces[1];
  }

  return braces[0] + base + ' ' + output.join(', ') + ' ' + braces[1];
}


// NOTE: These type checking functions intentionally don't use `instanceof`
// because it is fragile and can be easily faked with `Object.create()`.
function isArray(ar) {
  return Array.isArray(ar);
}
exports.isArray = isArray;

function isBoolean(arg) {
  return typeof arg === 'boolean';
}
exports.isBoolean = isBoolean;

function isNull(arg) {
  return arg === null;
}
exports.isNull = isNull;

function isNullOrUndefined(arg) {
  return arg == null;
}
exports.isNullOrUndefined = isNullOrUndefined;

function isNumber(arg) {
  return typeof arg === 'number';
}
exports.isNumber = isNumber;

function isString(arg) {
  return typeof arg === 'string';
}
exports.isString = isString;

function isSymbol(arg) {
  return typeof arg === 'symbol';
}
exports.isSymbol = isSymbol;

function isUndefined(arg) {
  return arg === void 0;
}
exports.isUndefined = isUndefined;

function isRegExp(re) {
  return isObject(re) && objectToString(re) === '[object RegExp]';
}
exports.isRegExp = isRegExp;

function isObject(arg) {
  return typeof arg === 'object' && arg !== null;
}
exports.isObject = isObject;

function isDate(d) {
  return isObject(d) && objectToString(d) === '[object Date]';
}
exports.isDate = isDate;

function isError(e) {
  return isObject(e) &&
      (objectToString(e) === '[object Error]' || e instanceof Error);
}
exports.isError = isError;

function isFunction(arg) {
  return typeof arg === 'function';
}
exports.isFunction = isFunction;

function isPrimitive(arg) {
  return arg === null ||
         typeof arg === 'boolean' ||
         typeof arg === 'number' ||
         typeof arg === 'string' ||
         typeof arg === 'symbol' ||  // ES6 symbol
         typeof arg === 'undefined';
}
exports.isPrimitive = isPrimitive;

exports.isBuffer = __webpack_require__(10);

function objectToString(o) {
  return Object.prototype.toString.call(o);
}


function pad(n) {
  return n < 10 ? '0' + n.toString(10) : n.toString(10);
}


var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep',
              'Oct', 'Nov', 'Dec'];

// 26 Feb 16:19:34
function timestamp() {
  var d = new Date();
  var time = [pad(d.getHours()),
              pad(d.getMinutes()),
              pad(d.getSeconds())].join(':');
  return [d.getDate(), months[d.getMonth()], time].join(' ');
}


// log is just a thin wrapper to console.log that prepends a timestamp
exports.log = function() {
  console.log('%s - %s', timestamp(), exports.format.apply(exports, arguments));
};


/**
 * Inherit the prototype methods from one constructor into another.
 *
 * The Function.prototype.inherits from lang.js rewritten as a standalone
 * function (not on Function.prototype). NOTE: If this file is to be loaded
 * during bootstrapping this function needs to be rewritten using some native
 * functions as prototype setup using normal JavaScript does not work as
 * expected during bootstrapping (see mirror.js in r114903).
 *
 * @param {function} ctor Constructor function which needs to inherit the
 *     prototype.
 * @param {function} superCtor Constructor function to inherit prototype from.
 */
exports.inherits = __webpack_require__(9);

exports._extend = function(origin, add) {
  // Don't do anything if add isn't an object
  if (!add || !isObject(add)) return origin;

  var keys = Object.keys(add);
  var i = keys.length;
  while (i--) {
    origin[keys[i]] = add[keys[i]];
  }
  return origin;
};

function hasOwnProperty(obj, prop) {
  return Object.prototype.hasOwnProperty.call(obj, prop);
}

/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(1), __webpack_require__(8)))

/***/ })
/******/ ]);
//# sourceMappingURL=viewerbundle.js.map