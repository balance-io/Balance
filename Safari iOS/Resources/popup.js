`use strict`;

let data = {
    address: `0x`,
    balance: `0.00`,
    chainId: `1`,
    ticker: `ETH`,
};

const views = {
    idleConnected: () => `
        <section class="section">
            <div class="network">
                <label for="network" class="network__label">Network</label>
                <select id="network" class="network__select">
                    <option>Ethereum Mainnet</option>
                </select>
            </div>
        </section>
        <section class="section">
            <p class="balance">${data.balance} ${data.ticker}</p>
            <p class="address">${data.address.slice(0, 21)}<br>${data.address.slice(-21)}</p>
        </section>
    `,
    idleNotConnected: () => `
        <section class="section">
            <p class="balance">Not connected</p>
        </section>
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
