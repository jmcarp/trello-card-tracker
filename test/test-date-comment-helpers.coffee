expect = require('chai').expect
app = require('../app')
helpers = require('./test-helpers.js')
q = require('q')
trello = require('node-trello')
sinon = require('sinon')
moment = require('moment')
require('sinon-as-promised')
DateCommentHelpers = new app.DateCommentHelpers()

describe 'app.DateCommentHelpers', ->
  describe '.hasMovedCheck(actionList)', ->
    it 'will return true if a card has a list of acitons that has not moved', ->
      hasMoved = DateCommentHelpers.hasMovedCheck(helpers.actionListMove)
      expect(hasMoved).to.eql [helpers.actionListMove[1]]
      return

    it 'will return false if a card has a list of acitons that has not moved', ->
      hasMoved = DateCommentHelpers.hasMovedCheck(helpers.actionListNoMove)
      expect(hasMoved).to.be.false
      return
    return

  describe 'checkCommentsForDates(commentList, latest, findEndDate)', ->
    beforeEach ->
      localMoment = undefined
      return
    afterEach ->
      localMoment = null
      return

    it 'will check if a comment has a date and return the first date in the lattest comment from a comment list', ->
      lastMoment = moment("2016-03-21").toISOString(); #to get out of localization of test suite
      prevMove = DateCommentHelpers.checkCommentsForDates(helpers.mockCommentCardObj.actions, true, false)
      expect(prevMove).to.eql lastMoment
      return

    it 'will check if a comment has a date and return the seconde date in the lattest comment from a comment list', ->
      lastMoment = moment("2016-03-08").toISOString(); #to get out of localization of test suite
      prevMove = DateCommentHelpers.checkCommentsForDates(helpers.mockCommentCardObj.actions, true, true)
      expect(prevMove).to.eql lastMoment
      return

    it 'will check if a comment has a date and return the first date from a comment list', ->
      localMoment = moment("2016-01-02").toISOString(); #to get out of localization of test suite
      commentList = JSON.parse(JSON.stringify(helpers.mockCommentCardObj.actions)) #clone to modify
      oldComment =
        id: '2'
        data: text: '**IAA Stage:** `+19 days`. *01/02/2016 - 03/08/2016*. Expected days: 2 days. Actual Days spent: 21.'
      commentList.push oldComment
      prevMove = DateCommentHelpers.checkCommentsForDates(commentList, false, false)
      expect(prevMove).to.eql localMoment
      return

    it 'will return false when there is no comment that matches the date string', ->
      comments = JSON.parse(JSON.stringify(helpers.mockCommentCardObj.actions))
      comments[0].data.text = "This comment has no date."
      prevMove = DateCommentHelpers.checkCommentsForDates(comments, true, false)
      expect(prevMove).to.be.false
      return
    return

  describe 'extractNewCommentFromDate(opts)', ->

    it 'will return the date if list of comments includes text with the dates in the MM/DD/YYYY -MM/DD/YYYY format ', ->
      localMoment = moment("2016-03-21").toISOString(); #to get out of localization of test suite
      prevMove = DateCommentHelpers.extractNewCommentFromDate({"commentList": helpers.mockCommentCardObj.actions, "actionList": helpers.actionListMove, "cardCreationDate": '2016-04-05T10:40:26.100Z'})
      expect(prevMove).to.eql localMoment
      return

    it 'will return the last Action date is there is actionList and there is no date in the commentcard', ->
      comments = JSON.parse(JSON.stringify(helpers.mockCommentCardObj.actions))
      comments[0].data.text = "This comment has no date."
      prevMove = DateCommentHelpers.extractNewCommentFromDate({"commentList": comments, "actionList": helpers.actionListMove, "cardCreationDate": '2016-04-05T10:40:26.100Z'})
      expect(prevMove).to.eql '2016-02-25T22:00:35.866Z'
      return

    it 'will return the creation date if there is no actionList or no current comment', ->
      comments = JSON.parse(JSON.stringify(helpers.mockCommentCardObj.actions))
      comments[0].data.text = "This comment has no date."
      prevMove = DateCommentHelpers.extractNewCommentFromDate({"commentList": comments, "cardCreationDate": '2016-04-05T10:40:26.100Z'})
      expect(prevMove).to.eql '2016-04-05T10:40:26.100Z'
      return

    it 'will return "01/01/2016 if there is nothing in the options', ->
      comments = helpers.mockCommentCardObj.actions
      comments[0].data.text = "This comment has no date."
      localMoment = moment("2016-01-01").toISOString()
      prevMove = DateCommentHelpers.extractNewCommentFromDate({})
      expect(prevMove).to.eql localMoment
      return
    return

  describe '.calcTotalDays(commentList, nowMoment)', ->
    it 'calculates takes a comment list and finds the oldest date and then calculates the total number of business days', ->
      comments = JSON.parse(JSON.stringify(helpers.mockCommentCardObj.actions)) #clone to modify
      oldComment =
        id: '2'
        data: text: '**IAA Stage:** `+19 days`. *01/02/2016 - 03/08/2016*. Expected days: 2 days. Actual Days spent: 21.'
      comments.push oldComment
      fakeNow = moment("2016-10-10")
      totalDays = DateCommentHelpers.calcTotalDays(comments, fakeNow)
      expect(totalDays).to.eql 195
      return

    it 'will return 0 if the comment list does not have and "MM/DD/YYYY - MM/DD/YYYY" regular expressions in the text', ->
      comments = JSON.parse(JSON.stringify(helpers.mockCommentCardObj.actions))
      comments[0].data.text = "This comment has no date."
      fakeNow = moment("2016-10-10")
      totalDays = DateCommentHelpers.calcTotalDays(comments, fakeNow)
      expect(totalDays).to.eql 0
      return
    return

  describe '.calculateDateDifference', ->
    it 'calculates the difference between when the card was moved and the expected time', ->
      difference = DateCommentHelpers.calculateDateDifference(10, "2016-04-05", "2016-07-27")
      expect(difference).to.eql [69,79]
      return
    return

  describe '.findHolidaysBetweenDates', ->
    it 'will not find a holiday between dates that do not have a holiday between them', ->
      holidays = DateCommentHelpers.findHolidaysBetweenDates(new Date('01-04-2016'), new Date('01-10-2016'))
      expect(holidays).to.eql 0
      return

    it 'will find that there are two holidays between 4/5/16 and 7/27/16', ->
      holidays = DateCommentHelpers.findHolidaysBetweenDates(new Date('2016-04-05'), new Date('2016-07-27'))
      expect(holidays).to.eql 2
      return
    return
  return
