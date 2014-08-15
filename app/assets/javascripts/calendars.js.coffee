# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ready page:load', ->

  # initialize the external events
  #-----------------------------------------------------------------
  $("#external-events div.external-event").each ->
      eventObject =
          title: $.trim($(this).attr("data-title"))
          icon: $.trim($(this).attr("data-icon"))
          description: $(this).attr("data-description")
          color: $(this).attr("data-color")
          holder: $(this).attr("data-holder")

      $(this).data "eventObject", eventObject
      $(this).draggable
          zIndex: 999
          revert: true
          revertDuration: 0

      return


  # initialize the calendar
  #	-----------------------------------------------------------------
  $('#calendar_admin').fullCalendar
      lang: 'uk',
      editable: true,
      header:
          left: 'prev,next today',
          center: 'title',
          right: 'month,agendaWeek,agendaDay'
      defaultView: 'month',
      events: {
        url: '/events',
        data: {
          calendar_id: $('#calendar_admin').attr('calendar_id')
        }
      },
#        timezone: false,
#        ignoreTimezone: true,
      timeFormat: 'H:mm',
      dragOpacity: "0.35"

      droppable: true
      drop: (date) ->
          originalEventObject = $(this).data("eventObject")

          copiedEventObject = $.extend({}, originalEventObject)

          # assign it the date that was reported
          copiedEventObject.start = date
          copiedEventObject.allDay = true

          createEvent(copiedEventObject)
          return

      selectable: true
      selectHelper: true
      select: (start, end, allDay) ->
          dt_start = (if start? then moment(start).format("DD/MM/YYYY") else "")
          dt_end = (if end? then moment(end).format("DD/MM/YYYY") else "")

          $.get "/events/new",
            calendar_id: $('#calendar_admin').attr('calendar_id')
            starts_at: dt_start
            all_day: true
          .done (data) ->
            $("#eventModal .modal-content").html data
            $('#eventModal').modal('show')

#            calendar.fullCalendar('unselect');

      eventClick: (calEvent, jsEvent, view) ->
          $.get("/events/"+calEvent.id).done (data) ->
              $("#eventModal .modal-content").html data
              $('#eventModal').modal('show')

      eventRender: (e, t, n) ->
          icon = (if e.icon then " <i class='fa " + e.icon + " '></i> " else "")
          i = (if e.description then e.description else "")
          t.find(".fc-event-title").before $("<span class=\"fc-event-icons\"></span>").html(icon)
          t.find(".fc-event-title").append "<br><small data-toggle='tooltip' data-placement='top' title='Tooltip'>" + i + "</small>"
          return

      eventResize: (event, dayDelta, minuteDelta, revertFunc) ->
          updateEvent(event);

      eventDrop: (event, dayDelta, minuteDelta, allDay, revertFunc) ->
          updateEvent(event);


  createEvent = (event) ->
      dt_start = (if event.start? then moment(event.start).format("YYYY-MM-DDTHH:mm:ss") else "")
      dt_end = (if event.end? then moment(event.end).format("YYYY-MM-DDTHH:mm:ss") else "")
      alert(1)
      $.ajax
          url: "/events/"
          type: 'POST'
          dataType: 'json'
          data:
              event:
                calendar: $('#calendar_admin').attr('calendar_id')
                icon: event.icon
                title: event.title
                description: event.description
                color: event.color
                starts_at_string: dt_start
                ends_at_string: dt_end
                all_day: event.allDay
                holder: event.holder
      .success (data) ->
          event.id = data.id
          $("#calendar_admin").fullCalendar "renderEvent", event, true
          $("#calendar_admin").fullCalendar "refetchEvents"

  updateEvent = (event) ->
      dt_start = (if event.start? then moment(event.start).format("YYYY-MM-DDTHH:mm:ss") else "")
      dt_end = (if event.end? then moment(event.end).format("YYYY-MM-DDTHH:mm:ss") else "")

      $.ajax
          url: "/events/" + event.id
          type: 'PUT'
          dataType: 'json'
          data:
              event:
                starts_at_string: dt_start,
                ends_at_string: dt_end,
                all_day: event.allDay
      .success ->
#            $("#calendar_admin").fullCalendar "refetchEvents"


  $('#eventModal').on "ajax:success", 'form',  (e, data, status, xhr) ->
      $("#calendar_admin").fullCalendar "refetchEvents"
      $('#eventModal').modal('hide')
