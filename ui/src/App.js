import React, { useState, useEffect, Component, useRef } from "react";
import Urbit from "@urbit/http-api";
import "./App.css";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import axios from "axios";

const UPLOAD_URL = "/apps/page/upload";

const fetchContents = (path) => {
	return window.urbit.scry({
    app: "page",
    path: path,
  });
}

const FileUploader = ({ onFileSelectSuccess, onFileSelectError }) => {
	const fileInput = useRef(null);

	const handleFileInput = (e) => {
		// handle validations
		const file = e.target.files[0];
		if (file.size > 90000)
			onFileSelectError({ error: "File size cannot exceed more than 90MB" });
		else onFileSelectSuccess(file);
	};

	return (
		<div className="file-uploader">
			<input type="file" onChange={handleFileInput} />
			{/* <button */}
			{/* 	onClick={(e) => fileInput.current && fileInput.current.click()} */}
			{/* 	className="btn btn-primary" */}
			{/* > */}
			{/* </button> */}
		</div>
	);
};

const Home = () => {
	const [link, setLink] = useState("");
	const [selectedFile, setSelectedFile] = useState(null);
	const [contents, setContents] = useState([]);

  useEffect(() => {
		fetchContents('/sites')
			.then(res => {
				setContents(res);
		})
			.catch(err => {
				alert("Failed to fetch info about pages");
		})
  }, []);

	const handleDelete = (link) => {
		console.log(link);
		console.log('delete clicked!');
		axios
			.delete(UPLOAD_URL, {
				headers: {
					"link": link,
				},
			})
			.then((res) => {
			})
			.catch((err) => alert("Delete Failed"));
		fetchContents('/sites')
			.then(res => {
				setContents(res);
		})
			.catch(err => {
				alert("Failed to fetch info about pages");
		})
	}

	const submitForm = () => {
		// TODO empty selected file should not be allowed
		const formData = new FormData();
		formData.append("link", link);
		formData.append("file", selectedFile);

		axios
			.post(UPLOAD_URL, formData, {
				headers: {
					"Content-Type": "multipart/form-data",
				},
			})
			.then((res) => {
				alert("File Upload success");
			})
			.catch((err) => alert("File Upload Error"));
		// (fetchContents('/sites'));
	};

	return (
		<div className="Home">
			<form>
				<input
					type="text"
					value={link}
					onChange={(e) => setLink(e.target.value)}
				/>

				<FileUploader
					onFileSelectSuccess={(file) => setSelectedFile(file)}
					onFileSelectError={({ error }) => alert(error)}
				/>

				<button onClick={submitForm}>Submit</button>
			</form>
		{ console.log(contents) }
		{ contents.map(link => {
			console.log(link);
			return (
				<div>
				<span>
				{link}
					<button onClick={() => handleDelete(link)}> Delete </button>
				</span>
				<br/>
				</div>
			);
		}) }
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
		return <Home />;
	}
}

export default App;
