// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

contract Book {
    uint length;
    uint breadth;
    uint height;
    constructor() {}

    function setDimensions(uint _length, uint _breadth, uint _height) public {
        length = _length;
        breadth = _breadth;
        height = _height;
    }

    function getDimensions() public view returns (uint, uint, uint) {
        return (length, breadth, height);
    }
}

contract Dimensions {
    Book book = new Book();
    function setDimensions(uint _length, uint _breadth, uint _height) public {
        book.setDimensions(_length, _breadth, _height);
    }

    function getDimensions() public view returns (uint, uint, uint) {
        return book.getDimensions();
    }
    function getInstance() public view returns (Book) {
        return book;
    }
}
