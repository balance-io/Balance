`use strict`;

let address = `0x`;
let balance = 0.00;

const views = {
    idle: () => `
        <p>${address}</p>
        <p>${balance}</p>
    `,
};

const $ = (query) =>
    query[0] === (`#`)
    ? document.querySelector(query)
    : document.querySelectorAll(query);

document.addEventListener(`DOMContentLoaded`, () => {
    browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
        if (typeof request.message.address !== `undefined` && typeof request.message.balance !== `undefined`) {
            address = request.message.address;
            balance = request.message.balance;
            $(`#body`).innerHTML = views.idle();
        }
    });
    browser.runtime.sendMessage({
        message: {
            message: `get_state`,
        },
    });
});
