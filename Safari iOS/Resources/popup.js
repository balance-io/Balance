`use strict`;

let data = {
    address: `0x`,
    balance: `0.00`,
    chainId: `1`,
    ticker: `ETH`,
};

const views = {
    idleConnected: () => `
        <p>${data.address}</p>
        <p>${data.balance} ${data.ticker}</p>
    `,
    idleNotConnected: () => `
        <p>Not connected</p>
    `,
};

const $ = (query) =>
    query[0] === (`#`)
    ? document.querySelector(query)
    : document.querySelectorAll(query);

document.addEventListener(`DOMContentLoaded`, () => {
    browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
        if (typeof request.message.address !== `undefined` && typeof request.message.balance !== `undefined` && typeof request.message.connected !== `undefined`) {
            if (request.message.connected === true) {
                data.address = request.message.address;
                data.balance = request.message.balance;
                $(`#body`).innerHTML = views.idleConnected();
            } else {
                $(`#body`).innerHTML = views.idleNotConnected();
            }
        }
    });
    browser.runtime.sendMessage({
        message: {
            message: `get_state`,
        },
    });
});
