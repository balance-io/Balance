function didMakeRequest(requestId, tabId) {
    pendingTabIds[requestId] = tabId;
}

function didCompleteRequest(id) {
    const request = { id: id, subject: "didCompleteRequest" };
    browser.runtime.sendNativeMessage("io.balance", request);
}

browser.runtime.onMessage.addListener(async (request, sender, sendResponse) => {
    if (typeof request.message === `undefined`) return;

    if (typeof request.message.message === `undefined`) return;

    switch (request.message.message) {
        case `get_state`: // * Send current method, address, balance, and network (?) to popup.js
            browser.tabs.query({
                active: true,
                currentWindow: true,
            }, (tabs) => {
                browser.tabs.sendMessage(tabs[0].id, {
                    message: `get_state_request`,
                });
            });
            break;
        case `get_state_response`:
            browser.runtime.sendMessage({
                message: {
                    address: request.message.address[0],
                    balance: request.message.balance,
                    chainId: request.message.chainId,
                    connected: request.message.connected,
                },
            });
            break;
        default: // * Unimplemented or invalid method
            console.log(`background [unimplemented]:`, request.message.message);
    }
});
