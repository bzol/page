import React, { useState, useEffect, Component, useRef } from "react";
import Urbit from "@urbit/http-api";
import "./App.css";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import axios from "axios";

const UPLOAD_URL = "/apps/page/upload";

const formatLink = (link) => {
	let newLink = link;
	if(newLink[0] !== '/')
		newLink = '/' + newLink;
	if(newLink[newLink.length -1] === '/')
		newLink = newLink.slice(0, newLink.length - 1);
	return newLink;
}

const fetchContents = (path) => {
	return window.urbit.scry({
		app: "page",
		path: path,
	});
};

const FileUploader = ({ onFileSelectSuccess, onFileSelectError }) => {
	const fileInput = useRef(null);

	const handleFileInput = (e) => {
		// handle validations
		const file = e.target.files[0];
		if (file.size > 100000)
			onFileSelectError({ error: "File size cannot exceed more than 100MB" });
		else onFileSelectSuccess(file);
	};

	return (
		<div className="file-uploader">
			<input type="file" onChange={handleFileInput} />
		</div>
	);
};

const Home = () => {
	const [link, setLink] = useState("");
	const [selectedFile, setSelectedFile] = useState(null);
	const [contents, setContents] = useState([]);

	useEffect(() => {
		fetchContents("/sites")
			.then((res) => {
				setContents(res);
			})
			.catch((err) => {
				alert("Failed to fetch info about pages");
			});
	}, []);

	const handleDelete = (link) => {
		axios
			.delete(UPLOAD_URL, {
				headers: {
					link: link,
				},
			})
			.then((res) => {})
			.catch((err) => alert("Delete Failed"));
		fetchContents("/sites")
			.then((res) => {
				setContents(res);
			})
			.catch((err) => {
				alert("Failed to fetch info about pages");
			});
	};

	const handleLinkChange = (link) => {

	}

	const submitForm = () => {
		// TODO empty selected file should not be allowed
		const formData = new FormData();
		formData.append("link", formatLink(link));
		formData.append("file", selectedFile);

		console.log(formatLink(link));

		if (selectedFile === null) {
			alert("No file chosen!");
			return;
		}
		const errorText = `Error: Make sure to use correct path, like:
your/path
your/path/filename.html`
		axios
			.post(UPLOAD_URL, formData, {
				headers: {
					"Content-Type": "multipart/form-data",
				},
			})
			.then((res) => {
				alert("File Upload success");
			})
			.catch((err) => alert(errorText));
		// (fetchContents('/sites'));
	};

	return (
		<div className="Home">
			<h1> %page application </h1>
			<a href="https://wiby.me/surprise" target="_blank">
				Surpise yourself/Inspiration
			</a>
			<form>
				<div className="form-inside">
					<text>Path:</text>
					<input
						className="form-input"
						type="text"
						value={link}
						onChange={(e) => setLink(e.target.value)}
					/>
				</div>

				<FileUploader
					className="form-inside"
					onFileSelectSuccess={(file) => setSelectedFile(file)}
					onFileSelectError={({ error }) => alert(error)}
				/>

				<button className="form-inside" onClick={submitForm}>
					Submit
				</button>
			</form>
			{contents.map((link) => {
				return (
					<div>
						<span>
							<text className="link">{link}</text>
							<button className="delete" onClick={() => handleDelete(link)}>
								{" "}
								Delete{" "}
							</button>
						</span>
						<br />
					</div>
				);
			})}
		</div>
	);
};

class App extends Component {
	constructor(props) {
		super(props);

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
