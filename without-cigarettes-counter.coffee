Days = new Meteor.Collection('days')

_MS_PER_DAY = 1000 * 60 * 60 * 24


dateDiffInDays = (a, b) ->
  utc1 = Date.UTC(a.getFullYear(), a.getMonth(), a.getDate())
  utc2 = Date.UTC(b.getFullYear(), b.getMonth(), b.getDate())

  Math.floor((utc2 - utc1) / _MS_PER_DAY)

dateDiff = (a, b) ->
  data = new Date(b - a)
 
  val = data.getFullYear() + " year "
  val += data.getMonth() + " month "
  val += data.getDay() + " days "
  val += data.getHours() + " hours "
  val += data.getMinutes() + " minutes "
  val += data.getSeconds() + " seconds "
  timestamp = data.getTime()
  days = Math.floor(timestamp / _MS_PER_DAY)
  timestamp = timestamp - days * _MS_PER_DAY
  hours = Math.floor(timestamp / (1000 * 60 * 60))
  timestamp = timestamp - (hours * (1000 * 60 * 60))
  minutes = Math.floor(timestamp / (1000 * 60))
  timestamp = timestamp - (minutes * (1000 * 60))
  seconds = Math.floor(timestamp / 1000)

  val = days + " days, "
  val += hours + " hours "
  val += minutes + " minutes and "
  val += seconds + " seconds ago!"

  
if Meteor.isClient
  Meteor.subscribe 'days'
  Template.counter.helpers
    days: ()->
      days = if Meteor.userId()
        Days.find({owner: Meteor.userId()})
      else
        null

  Template.counter.events
    'click button.start': (evt) ->
      evt.stopPropagation()
      Meteor.call('startCounter')
      $(evt.target).removeClass('start')
      $(evt.target).addClass('restart')

  Template.day.helpers
    displayElapsedTime: ()->
      setInterval(1000, dateDiff(@createdAt, new Date()))
      dateDiff(@createdAt, new Date())
      

  Accounts.ui.config
    passwordSignupFields: "USERNAME_ONLY"

if Meteor.isServer
  Meteor.publish "days", () ->
    Days.find(
      { owner: @userId }
    )

Meteor.methods
  startCounter: () ->
    if not Meteor.userId()
      throw new Meteor.Error("not-authorized")
    Days.insert
      createdAt: new Date()
      owner: Meteor.userId()
      private: false
      username: Meteor.user().username

  restartCounter: () ->
    if not meteor.userId()
      throw new Meteor.Error('not-authorized')
    Meteor.call('startCounter')