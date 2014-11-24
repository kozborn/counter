Days = new Meteor.Collection('days')

_MS_PER_DAY = 1000 * 60 * 60 * 24


dateDiffInDays = (a, b) ->
  utc1 = Date.UTC(a.getFullYear(), a.getMonth(), a.getDate())
  utc2 = Date.UTC(b.getFullYear(), b.getMonth(), b.getDate())

  Math.floor((utc2 - utc1) / _MS_PER_DAY)

if Meteor.isClient
  Meteor.subscribe 'days'
  Session.set "DocumentTitle", "Days without cigarettes counter"
  dateDiff = () ->
    a = Session.get 'createdAt'
    b = new Date()
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
    val = ""
    if days > 0
      val += days + " days,<br/> "
    if hours > 0
      val += hours + " hours, "
    val += minutes + " minutes and <br/>"
    val += seconds + " seconds ago!"

    documentTitle = ""
    if days > 0
      documentTitle += days + " d, "
    if hours > 0
      documentTitle += hours + "h: "
    documentTitle += minutes + "m: "
    documentTitle += seconds + "s ago!"

    Session.set 'dateDiff' , val
    Session.set 'DocumentTitle', documentTitle

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

  Template.day.helpers
    displayElapsedTime: ()->
      setInterval(1000, dateDiff(@createdAt, new Date()))
      Session.set 'createdAt', @createdAt
      dateDiff()
      Session.get 'dateDiff'

  Template.day.destroyed = () ->
    Meteor.clearInterval dateDiff

  Meteor.setInterval dateDiff, 1000

  Accounts.ui.config
    passwordSignupFields: "USERNAME_ONLY"

  Deps.autorun () ->
    document.title = Session.get "DocumentTitle"

if Meteor.isServer
  Meteor.publish "days", () ->
    Days.find(
      { owner: @userId }
    )

Meteor.methods
  startCounter: () ->
    if not Meteor.userId()
      throw new Meteor.Error("not-authorized")
    if Days.find({ owner: Meteor.userId() }).count() > 0
      if confirm "Are you sure! Your counter will be reset"
        Days.remove({ owner: Meteor.userId() })
        Days.insert
          createdAt: new Date()
          owner: Meteor.userId()
          private: false
          username: Meteor.user().username
    else
      Days.insert
            createdAt: new Date()
            owner: Meteor.userId()
            private: false
            username: Meteor.user().username