
var MyExtensionJavaScriptClass = function() {};

MyExtensionJavaScriptClass.prototype = {
    getImage: function() {
        var metas = document.getElementsByTagName('img');
        var metaContents = "";
        metaContents = ( metas[0].getAttribute("src"));
        for (i=1; i<metas.length; i++) {
                metaContents = metaContents + "'#~@"+( metas[i].getAttribute("src"));
        }
        return metaContents;
    },
    getPrice: function() {
        var str = document.body.innerText;
        var price = str.match(/£\S+/g)[0];
       // price = price.replace('£', '')
        return price.replace(/\s/g,'');
    },
    
    getURL: function(){
       var canonical = "";
               var links = document.getElementsByTagName("link");
               for (var i = 0; i < links.length; i ++) {
                   if (links[i].getAttribute("rel") === "canonical") {
                       canonical = links[i].getAttribute("href")
                   }
               }
       return canonical;
   },

    run: function(arguments) {
    // Pass the baseURI of the webpage to the extension.
        arguments.completionFunction({"url": document.baseURI, "host": document.location.hostname, "title": document.title, "price":this.getPrice(), "image": this.getImage(), "ProdURL": this.getURL()});
    },
// Note that the finalize function is only available in iOS.
    finalize: function(arguments) {
        // arguments contains the value the extension provides in [NSExtensionContext completeRequestReturningItems:completion:].
    // In this example, the extension provides a color as a returning item.
    // document.body.style.backgroundColor = arguments["bgColor"];
    }
};

// The JavaScript file must contain a global object named "ExtensionPreprocessingJS".
var ExtensionPreprocessingJS = new MyExtensionJavaScriptClass;
