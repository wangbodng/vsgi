using Soup;
using Valum;

var app = new Valum.Router();
var lua = new Valum.Script.Lua();
var mcd = new Valum.NoSQL.Mcached();

mcd.add_server("127.0.0.1", 11211);

var tpl = new Valum.View.Tpl.from_string("""
   <p> hello {foo} </p>
   <p> hello {bar} </p>
   <ul>
	 { for el in arr }
	   <li> { el } </li>
	 { end }
   </ul>
""");

app.get("ctpl/<foo>/<bar>", (req, res) => {

	var arr = new Gee.ArrayList<Value?>();
	arr.add("omg");
	arr.add("typed hell");

	tpl.vars["foo"] = req.params["foo"];
	tpl.vars["bar"] = req.params["bar"];
	tpl.vars["arr"] = arr;
	tpl.vars["int"] = 1;

	res.append(tpl.render ());
});


// Just sample to benchmark against node
app.get("node.js.vs.valum", (req, res) => {
	res.mime = "text/plain";
	res.append("Hello world\n");
});


app.get("users/<int:id>/<action>", (req, res) => {
	var id   = req.params["id"];
	var test = req.params["test"];
	res.append(@"id => $id<br/>");
	res.append(@"test => $test<br/>");
});

app.get("lua", (req, res) => {
	res.append(lua.eval("""
		require "markdown"
		return markdown('## Hello from lua.eval!')
	"""));

	res.append(lua.run("app/hello.lua"));
});

app.get("lua.haml", (req, res) => {
	res.append(lua.run("app/haml.lua"));
});

app.get("memcached/set/<key>/<value>", (req, res) => {
	if (mcd.set(req.params["key"], req.params["value"])) {
		res.append("Ok! Pushed.");
	} else {
		res.append("Fail! Not Pushed...");
	}
});

app.get("memcached/get/<key>", (req, res) => {
	var value = mcd.get(req.params["key"]);
	res.append(value);
});

// FIXME: Optimize routing...
// for (var i = 0; i < 1000; i++) {
//		print(@"New route /$i\n");
//		var route = "%d".printf(i);
//		app.get(route, (req, res) => { res.append(@"yo 1"); });
// }

app.scope("admin", (adm) => {
	adm.scope("fun", (fun) => {
		fun.get("hack", (req, res) => {
				res.append("no way!");
				res.append("<br/>");
				var time = new DateTime.now_utc();
				res.append(time.format("%H:%M"));
		});
		fun.get("heck", (req, res) => {
				res.append("fuck!");
		});
	});
});

app.get("hello/<id>", (req, res) => {
	res.mime = "text/plain";
	res.append("");
	res.append(req.params["id"]);
});

app.get("yay", (req, res) => {
	res.append("yay");
	res.append("<br/>");
	res.append("hell yeah");
});

app.get("", (req, res) => {
	var template =  new Valum.View.Tpl.from_path("app/templates/home.html");

	template.vars["path"] = req.message.uri.get_path ();
	template.vars["query"] = req.message.uri.get_query ();
	template.vars["headers"] = req.headers;

	res.append(template.render());
});

var server = new Soup.Server(Soup.SERVER_SERVER_HEADER, Valum.APP_NAME);

// bind the application to the server
server.add_handler("/", app.request_handler);

try {
	server.listen_local(3000, Soup.ServerListenOptions.IPV4_ONLY);
} catch (Error error) {
	stderr.printf("%s.\n", error.message);
}

stdout.printf("Point your browser at http://localhost:3000.\n");

// run the server
server.run ();