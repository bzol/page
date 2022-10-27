import React, { useState, useEffect, Component, useRef } from "react";
import Urbit from "@urbit/http-api";
import "./App.css";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import axios from "axios";

const UPLOAD_URL = "/apps/page/upload";

const formatLink = (link) => {
	let newLink = link;
	if (newLink[0] !== "/") newLink = "/" + newLink;
	if (newLink[newLink.length - 1] === "/")
		newLink = newLink.slice(0, newLink.length - 1);
	return newLink;
};

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
		if (file.size > 1000000)
			onFileSelectError({ error: "File size cannot exceed more than 1MB" });
		else onFileSelectSuccess(file);
	};

	return (
		<label className="button fileuploader">
			Choose File
			<input
				className="fileuploader-input"
				type="file"
				onChange={handleFileInput}
			/>
		</label>
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

	const handleLinkChange = (link) => {};

	const submitForm = () => {
		const formData = new FormData();
		formData.append("link", formatLink(link));
		formData.append("file", selectedFile);

		if (selectedFile === null) {
			alert("No file chosen!");
			return;
		}
		const errorText = `Error: Make sure to use correct path, like:
your/path
your/path/filename.html`;
		axios
			.post(UPLOAD_URL, formData, {
				headers: {
					"Content-Type": "multipart/form-data",
				},
			})
			.then((res) => {
				console.log(res);
				fetchContents("/sites")
					.then((res) => {
						setContents(res);
					})
					.catch((err) => {
						alert("Failed to fetch info about pages");
					});
				alert("File Upload success");
			})
			.catch((err) => alert(errorText));
	};

	return (
		<div className="Home">
			<div>
				<h1> %page application </h1>
				<a
					className="button surprise"
					href="https://wiby.me/surprise"
					target="_blank"
				>
					Surprise yourself
				</a>
			</div>
			<h4>Find your pages under yourdomain/p/ </h4>
			<form>
				<input
					className="path"
					type="text"
					placeholder="Path"
					value={link}
					onChange={(e) => setLink(e.target.value)}
				/>

				<FileUploader
					onFileSelectSuccess={(file) => setSelectedFile(file)}
					onFileSelectError={({ error }) => alert(error)}
				/>

				<button className="button submit" onClick={submitForm}>
					Submit
				</button>
			</form>
			{contents.map((link) => {
				return (
					<div className="upload">
						<span className="upload-item">
							<text className="link">{link}</text>
							<button
								className="button delete"
								onClick={() => handleDelete(link)}
							>
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
