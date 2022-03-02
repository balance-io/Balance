browser.tabs.getSelected(null, tab => {
	console.log({tab})
	
	browser.tabs.sendMessage(tab.id, { subject: "getAppearAs" }, response => {
		console.log(response);
		const { hostname } = new URL(tab.url);
		if (!hostname) return;

		const button = document.getElementById("appear-as-button");
		requestAnimationFrame(() => {
			button.appendChild(document.createTextNode(`Appear as ${response === 0 ? "MetaMask" : "Balance"} for`));
			button.appendChild(document.createElement("br"));
			button.appendChild(document.createTextNode(hostname));
			button.classList.remove("hidden");
		})
		button.addEventListener("click", () => {
			const request = { subject: "setAppearAs", wallet: response === 0 ? 1 : 0, hostname };
			browser.tabs.sendMessage(tab.id, request, success => {
				if (success) {
					window.close();
				}
			});
		});
	});
});
