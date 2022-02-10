`use strict`;

const networks = [
    {
        chainId: 1,
        name: `Ethereum Mainnet`,
        ticker: `ETH`,
    },
    {
        chainId: 42161,
        name: `Arbitrum One`,
        ticker: `ETH`,
    },
    {
        chainId: 137,
        name: `Polygon Mainnet`,
        ticker: `MATIC`,
    },
    {
        chainId: 10,
        name: `Optimism`,
        ticker: `OETH`,
    },
    {
        chainId: 56,
        name: `Binance Smart Chain Mainnet`,
        ticker: `BNB`,
    },
    {
        chainId: 43114,
        name: `Avalanche Mainnet`,
        ticker: `AVAX`,
    },
    {
        chainId: 100,
        name: `Gnosis Chain`,
        ticker: `xDAI`,
    }
];

const getNetworkSelectionHTML = () => {
    let options = ``;
    const networkCount = networks.length;
    for (let i = 0; i < networkCount; i++) {
        const network = networks[i];
        options += `<option value="${network.chainId}">${network.name}</option>`;
    }
    return options;
};

const getNetworkByChainId = (id) => {
    const index = networks.indexOf(networks.find((e) => e.chainId === id));
    return index !== -1 ? networks[index] : null;
};

let data = {
    address: `0x`,
    balance: `0.00`,
    chainId: 1,
    network: `Ethereum Mainnet`,
    ticker: `ETH`,
};

const views = {
    idleConnected: () => `
        <section class="section">
            <div class="network">
                <label for="network" class="network__label">Network</label>
                <select id="network" class="network__select">
                    ${getNetworkSelectionHTML()}
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
        if (typeof request.message.address !== `undefined` && typeof request.message.balance !== `undefined` && typeof request.message.chainId !== `undefined` && typeof request.message.connected !== `undefined`) {
            if (request.message.connected === true) {
                data.address = request.message.address;
                data.balance = request.message.balance;
                data.chainId = request.message.chainId;
                const network = getNetworkByChainId(data.chainId);
                if (network !== null) {
                    data.network = network.name;
                    data.ticker = network.ticker;
                }
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
