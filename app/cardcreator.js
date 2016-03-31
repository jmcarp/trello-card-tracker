"use strict";

var fs = require('fs');
var yaml = require('js-yaml');
var Q = require('q');
var _ = require("underscore");

var MyTrello = require("./my-trello.js");
require('./utils.js');


class CardCreator extends MyTrello {
    constructor(yaml_file, board) {
        super(yaml_file, board);
        this.stages = this.getPreAward();
    }

    createOrders(orderFile) {
        var orders = yaml.safeLoad(fs.readFileSync(orderFile, 'utf8')),
            promises = [],
            self = this;

        _.each(orders.orders, function(order) {
            promises.push(self.createCard(order));
        });

        return Q.all(promises);
    }

    createCard(order) {
        var deferred = Q.defer();

        var description = this.descriptionMaker(order),
            cardName = order.project + " - " + order.order,
            due = order.due || null,
            self = this;

        this.getListIDbyName(order.stage).then(function(listID) {
            var cardInfo = {
                name: cardName,
                desc: description,
                idList: listID,
                due: due
            };
            self.t.post('1/cards/', cardInfo, function(err, data) {
                if (err) return deferred.reject(new Error(err));
                deferred.resolve(data);
            });
        });

        return deferred.promise;
    }

    descriptionMaker(order) {
        var result = "Project: {p}\nAgency: {a}\nSubAgency: {sub}\nTrello Board: {tb}".supplant({
            p: order.project,
            a: order.agency,
            sub: order.subagency,
            tb: order.trello
        });
        return result;   
    }

}


module.exports = CardCreator;
