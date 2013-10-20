import ceylon.html {
    Node,
    Html,
    Element,
    TextNode,
    blockTag,
    CssClass,
    ParentNode,
    Snippet,
    StyledElement,
    BaseElement
}

shared class NodeSerializer(
    "A stream to direct output to"
    void print(String string),
    "Serialization options"
    SerializerConfig config = SerializerConfig()
) {

    variable value indentLevel = 0;

    variable value sizeCount = 0;

    value prettyPrint = config.prettyPrint;

    shared void serialize(Node root) => visit(root);

    shared Integer contentLength => sizeCount;

    void doPrint(String string) {
        sizeCount += string.size; // TODO accurate byte size?
        print(string);
    }

    void visitAny(Node|{Node*}|Snippet<Node> child) {
        if (is Node child) {
            visit(child);
        } else if (is {Node*} child) {
            visitNodes(child);
        } else if (is Snippet<Node> child,
                exists content = child.content) {
            visitAny(content);
        }
    }
    
    void visit(Node node) {
        if (is Html node) {
            startHtml(node);
        }
        indent();
        openTag(node);
        if (is Element node) {
            visitElement(node);
        }
        endOpenTag(node);
        indentLevel++;
        if (is TextNode node, !node.text.trimmed.empty) {
            linefeed();
            indent();
            doPrint(node.text);
        }
        if (is ParentNode<Node> node) {
            for (child in node.children) {
                if (exists child) {
                    linefeed();
                    visitAny(child);
                }
            }
        }
        indentLevel--;
        if (node.tag.type == blockTag) {
            linefeed();
            indent();
            closeTag(node);
        }
    }

    void startHtml(Html html) {
        doPrint(html.doctype.string);
        linefeed(true);
        linefeed();
    }

    void visitElement(Element node) {
        printAttributes(node);
    }

    void openTag(Node node) => doPrint("<``node.tag.name``");

    void endOpenTag(Node node) {
        //if (node.tag.type == inlineTag) {
        //    if (exists doctype, doctype in xhtmlDoctypes) {
        //        doPrint("/");
        //    }
        //}
        doPrint(">");
    }

    void closeTag(Node node) => doPrint("</``node.tag.name``>");

    void printAttributes(Element node) {
        printAttribute("id", node.id);
        if (is StyledElement node) {
            printCssClassAttribute(node.classNames);
            printAttribute("style", node.style);
        }
        if (is BaseElement node) {
            printAttribute("title", node.title);
            printAttribute("accesskey", node.accessKey);
            printAttribute("contextmenu", node.contextMenu);
            printAttribute("dir", node.dir);
            printAttribute("draggable", node.draggable);
            printAttribute("dropzone", node.dropZone);
            printAttribute("hidden", node.hidden);
            printAttribute("inert", node.inert);
            printAttribute("lang", node.lang);
            printAttribute("spellcheck", node.spellcheck);
            printAttribute("tabindex", node.tabIndex);
            printAttribute("translate", node.translate);

            for (name->val in node.attributes) {
                printAttribute(name, val.string);
            }

            for (name->val in node.data) {
                printAttribute("data-``name``", val.string);
            }
        }
    }

    void printAttribute(String name, Object? val) {
        if (exists val) {
            doPrint(" ``name``=\"``val``\"");
        }
    }

    void printCssClassAttribute(CssClass classNames) {
        variable String? cls = null;
        switch(classNames)
        case(is String) {
            cls = classNames;
        }
        case(is [String*]) {
            cls = " ".join(classNames);
        }
        if (exists cssClass = cls, !cssClass.trimmed.empty) {
            printAttribute("class", cssClass);
        }
    }

    void visitNodes({Node*} nodes) {
        for (node in nodes) {
            visit(node);
        }
    }

    void linefeed(Boolean force = false) {
        if (prettyPrint || force) {
            doPrint(operatingSystem.newline);
        }
    }

    void indent() {
        if (prettyPrint) {
            doPrint(indentString);
        }
    }

    String indentString {
        value spaces = indentLevel * 4;
        return spaces > 0 then " ".repeat(spaces) else "";
    }

}

"A [[NodeSerializer]] implementation that prints content on console."
shared NodeSerializer consoleSerializer = NodeSerializer(process.write);
