import { LightningElement, api } from 'lwc';

export default class CustomImage extends LightningElement {
    @api url;
    @api altText;

    // get imageSrc() {
    //     return `/servlet/servlet.FileDownload?file=${this.value}`;
    // }
}
