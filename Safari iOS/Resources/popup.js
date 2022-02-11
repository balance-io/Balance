`use strict`;

const connectedSVG = `<svg width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="6" cy="6" r="6" fill="#03C78D"/></svg>`;
const disconnectedSVG = `<svg width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="6" cy="6" r="6" fill="#03C78D"/><circle cx="6" cy="6" r="6" fill="#D7D7D7"/></svg>`;
const balanceLogoSVG = `<svg width="23" height="26" viewBox="0 0 23 26" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" clip-rule="evenodd" d="M13.3605 0.511521L15.2375 1.61862L4.35768 8.04733C4.16828 8.15799 4.01105 8.31802 3.90209 8.51106C3.79312 8.7041 3.73633 8.92323 3.7375 9.14604V13.1718L0 10.9618V8.387C0.000771924 7.71889 0.172945 7.06264 0.499376 6.4836C0.825806 5.90456 1.2951 5.42294 1.86054 5.08668L9.63947 0.473779C10.2076 0.143544 10.8513 -0.0269518 11.505 -0.0203216C12.1587 -0.0136913 12.799 0.169827 13.3605 0.511521ZM12.1202 21.8064L15.525 19.7935V24.2093L13.3605 25.4673C12.7957 25.8033 12.1537 25.9803 11.5 25.9803C10.8463 25.9803 10.2043 25.8033 9.63947 25.4673L1.86054 20.8544C1.30343 20.5232 0.839465 20.0509 0.513526 19.483C0.187587 18.9151 0.010708 18.2709 0 17.6128V15.3776L10.8798 21.8064C11.0681 21.9183 11.2821 21.9773 11.5 21.9773C11.7179 21.9773 11.9319 21.9183 12.1202 21.8064ZM21.1559 5.10346L18.975 3.82442L15.2375 6.03442L18.6423 8.04733C18.8317 8.15799 18.9889 8.31802 19.0979 8.51106C19.2069 8.7041 19.2637 8.92323 19.2625 9.14604V22.0035L21.1395 20.8964C21.7025 20.5615 22.1703 20.0826 22.4965 19.5067C22.8228 18.9309 22.9964 18.2781 23 17.6128V8.387C22.9964 7.72174 22.8228 7.06895 22.4965 6.4931C22.1703 5.91726 21.7025 5.43827 21.1395 5.10346H21.1559Z" fill="white"/></svg>`;

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
        name: `Binance Smart Chain`,
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
    debug: () => `
        <section class="section">
            <p class="balance">${data.network} (${data.chainId})</p>
            <p class="balance">${data.balance} ${data.ticker}</p>
            <p class="address">${data.address.slice(0, 21)}<br>${data.address.slice(-21)}</p>
        </section>
        <div class="wrapper">
            <button id="button" class="button">
                ${balanceLogoSVG}<span>Open Balance App</span>
            </button>
        </div>
    `,
    idleConnected: () => `
        <section class="connected">
            ${connectedSVG}<p class="connected__text">Connected</p>
        </section>
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
        <div class="wrapper">
            <button id="button" class="button">
                ${balanceLogoSVG}<span>Open Balance App</span>
            </button>
        </div>
    `,
    idleNotConnected: () => `
        <section class="connected">
            ${disconnectedSVG}<p class="connected__text">Not connected</p>
        </section>
        <div class="wrapper">
            <button id="connect" class="button">
                <span>Force Connect</span>
            </button>
        </div>
        <div class="wrapper">
            <button id="button" class="button">
                ${balanceLogoSVG}<span>Open Balance App</span>
            </button>
        </div>
    `,
};

const $ = (query) =>
    query[0] === (`#`)
    ? document.querySelector(query)
    : document.querySelectorAll(query);

const render = (query, view) =>
    $(query).innerHTML = view(); // todo sanitize?

document.addEventListener(`DOMContentLoaded`, async () => {
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
                $(`#connect`).onclick = () => {
                    setTimeout(() => {
                        $(`#connect`).innerHTML = `Force Connect`;
                    }, 1000);
                    $(`#connect`).innerHTML = `Coming soon!`;
                };
                // for debugging: $(`#body`).innerHTML = views.debug();
            }
            $(`#button`).onclick = () => window.open(`balance://`);
        }
    });
    browser.runtime.sendMessage({
        message: {
            message: `get_state`,
        },
    });



    const result = await browser.runtime.sendNativeMessage("io.balance", {id: 1, subject: "getAccounts"});
    const log = document.createElement('div')
    log.style.color = "black"
    log.textContent = JSON.stringify(result)
    document.body.appendChild(log)

    const chains = await browser.runtime.sendNativeMessage("io.balance", {id: 1, subject: "getChains"});
    const log2 = document.createElement('div')
    log2.style.color = "black"
    log2.textContent = JSON.stringify(chains)
    document.body.appendChild(log2)
});
