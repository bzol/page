import React, { useState, useEffect, Component } from "react";
import Urbit from "@urbit/http-api";
import "./App.css";
import { BrowserRouter, Routes, Route } from "react-router-dom";

const Home = () => {
	return (
		<div>
		<form
			method="post"
			enctype="multipart/form-data"
			action="/apps/page/upload"
		>
			<label>
				Choose page:
				<input type="file" name="file" />
				<label>Choose link: </label>
				<input type="text" name="link" />
			</label>
			<button type="submit">Upload</button>
		</form>
		</div>
	);
};

class App extends Component {
	constructor(props) {
		super(props);

		// window.urbit = new Urbit("http://localhost:8080","","lidlut-tabwed-pillex-ridrup");
		// window.urbit.ship = 'zod';
		// window.urbit = new Urbit("http://localhost:8081","","ranser-masfyr-parwyd-sabdux");
		// window.urbit.ship = 'taclev-togpub-pontus-fadpun';
		// window.urbit = new Urbit("http://localhost:8080","","magsub-micsev-bacmug-moldex");
		// window.urbit.ship = 'dev';

		window.urbit = new Urbit("");
		window.urbit.ship = window.ship;

		window.urbit.onOpen = () => this.setState({ conn: "ok" });
		window.urbit.onRetry = () => this.setState({ conn: "try" });
		window.urbit.onError = () => this.setState({ conn: "err" });
		// scryGroup('');
	}
	render() {
		return (
			<Home/>
		);
	}
}

export default App;
{
	/* <form method="post" enctype="multipart/form-data"><label>desk: <select name="desk"><option value="garden">garden</option><option value="webterm">webterm</option><option value="landscape">landscape</option><option value="gather">gather</option><option value="bitcoin">bitcoin</option></select></label><br><label>data: <input type="file" name="glob" directory="" webkitdirectory="" mozdirectory=""></label><br><button type="submit">glob!</button></form> */
}
// )
