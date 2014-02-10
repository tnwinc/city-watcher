App.ProgressBarComponent = Ember.Component.extend

  classNames: ['progress-bar']

  style: (->
    "width: #{@get 'value'}%"
  ).property 'value'
