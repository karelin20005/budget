class PublicController < ApplicationController
  before_action :set_calendar, only: [:calendar, :pie_data, :timelinejs, :subscribe, :unsubscribe]

  def index
  end

  def calendar
    @timeline_events = build_timeline @calendar.events
    @current_event1 = get_current_event @calendar.events.current_event(1).first
    @current_event2 = get_current_event @calendar.events.current_event(2).first
    @countdown_event = @calendar.events.where(:id => @calendar.countdown_event).first if @calendar.countdown_event
    @subscriber = @calendar.subscribers.where(:email => cookies['subscriber']).first unless cookies['subscriber'].nil?
  end

  def pie_data
    starts_at = '2014-01-01'.to_date #Event.asc(:starts_at).limit(1).first.starts_at.to_date
    ends_at = '2015-01-01'.to_date #Event.desc(:ends_at).limit(1).first.ends_at.to_date

    events = { e1: [], e2: [] }

    events[:e1] = build_pie starts_at, ends_at, @calendar.events.event_timeline(1, starts_at, ends_at)
    events[:e2] = build_pie starts_at, ends_at, @calendar.events.event_timeline(2, starts_at, ends_at)

    render json: { starts_at: starts_at.strftime('%d/%m/%Y'), ends_at: ends_at.strftime('%d/%m/%Y'), days: (ends_at - starts_at) / 3600 / 24 , events1: events[:e1], events2: events[:e2] }
  end

  def subscribe
    email = subscriber_params[:email]
    @subscriber = Subscriber.where(:email => email).first || Subscriber.new(:email => email)
    @calendar.subscribers << @subscriber if @calendar.subscribers.where(:email => @subscriber.email).empty?

    respond_to do |format|
      if @subscriber.save
        response.set_cookie('subscriber', @subscriber.email)
        format.js
      else
        format.json { render json: @subscriber.errors, status: :unprocessable_entity }
      end
    end
  end

  def timelinejs
    starts_at = '2014-01-01'.to_date #Event.asc(:starts_at).limit(1).first.starts_at.to_date
    ends_at = '2015-01-01'.to_date #Event.desc(:ends_at).limit(1).first.ends_at.to_date

    timeline = {
        'timeline' => {
          'headline'=>@calendar.title,
          'type'=>'default',
          'text' => @calendar.description,
          'startDate' => '2014,01,01',
          'asset'=>
              {
                  'media'=>'https=>//vine.co/v/b55LOA1dgJU',
                  'credit'=>'credit',
                  'caption'=>'caption'
              },
          'date' => []
        }
    }
    @calendar.events.all.each { |e|
      point = {}
      point['startDate'] = e.starts_at.strftime("%Y,%m,%d")
      point['endDate'] = e.ends_at.strftime("%Y,%m,%d") unless e.ends_at.nil?
      point['headline'] = "#{e.holder_text} - #{e.title}"
      point['text'] = e.description
      point['asset'] =
          {
              'media'=>'http://www.thejournal.ru/foto/f/12924387589.jpg',
              'thumbnail'=>'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcRr3edmflwvOiKZFhl9BVhZTJBR7cL2scqXW11W8AT5gPu7sQW4',
              'credit'=>'',
              'caption'=>''
          }

      timeline['timeline']['date'] << point
    }

    text =
        {
            'timeline'=>
                {
                    'headline'=>'Бюджетний календар - послідовність дій',
                    'type'=>'default',
                    'text'=>'People say stuff',
                    'startDate'=>'2012,1,26',
                    'asset'=>
                        {
                            'media'=>'https=>//vine.co/v/b55LOA1dgJU',
                            'credit'=>'',
                            'caption'=>''
                        },
                    'date'=> [
                        {
                            'startDate'=>'2011,12,12',
                            'endDate'=>'2012,1,27',
                            'headline'=>'Vine',
                            'text'=>'<p>Vine Test</p>',
                            'asset'=>
                                {
                                    'media'=>'https=>//vine.co/v/b55LOA1dgJU',
                                    'thumbnail'=>'',
                                    'credit'=>'',
                                    'caption'=>''
                                }
                        },
                        {
                            'startDate'=>'2012,3,18',
                            'headline'=>'Sh*t New Yorkers Say',
                            'text'=>'',
                            'asset'=>
                                {
                                    'media'=>'http=>//youtu.be/yRvJylbSg7o',
                                    'thumbnail'=>'',
                                    'credit'=>'',
                                    'caption'=>'Directed and Edited by Matt Mayer, Produced by Seth Keim, Written by Eliot Glazer. Featuring Eliot and Ilana Glazer, who are siblings, not married.'
                                }
                        }
                    ]
                }
        }

    #binding.pry
    render json: timeline

  end

  def unsubscribe
    @calendar.subscribers.delete(Subscriber.find(params[:subscriber_id]))
    @calendar.save
    response.delete_cookie('subscriber')
  end

  protected

  def get_current_event event
    return {} if event.nil? || (event.ends_at.to_date - event.starts_at.to_date) == 0
    percent = 100 * (Date.current - event.starts_at.to_date).to_i / (event.ends_at.to_date - event.starts_at.to_date).to_i
    { event: event, title: event.title, holder_text: event.holder_text, percent: percent}
  end

  def build_pie starts_at, ends_at, ev
    #binding.pry
    pie = [ { ends_at: starts_at, events: [] }]
    ev.map { |e|
      cycle = pie.detect {|dt| dt[:ends_at] <= e[:starts_at]}

      if cycle.nil?
        new_ev = build_event_for_pie( { :title => '', :description => '', starts_at: starts_at, ends_at: e[:starts_at], color: 'transparent' } )
        cycle = { ends_at: e[:ends_at], events: [ new_ev ] }
        pie << cycle
      end

      cycle[:events] << build_event_for_pie( { :title => '', :description => '', starts_at: cycle[:ends_at], ends_at: e[:starts_at], color: 'transparent' } ) if cycle[:ends_at] < e[:starts_at]
      cycle[:events] << build_event_for_pie(e)
      cycle[:ends_at] = e[:ends_at]

    }

    pie.each { |p|
      if p[:ends_at] < ends_at
        p[:events] << build_event_for_pie( { :title => '', :description => '', starts_at: p[:ends_at], ends_at: ends_at, color: 'transparent' } )
      end
    }

    # binding.pry
    pie

      # if end_at.nil?
      #   if e.starts_at > starts_at
      #     new_ev = { :title => '', :description => '', starts_at: starts_at, ends_at: e.starts_at, color: 'transparent' }
      #     events << build_event_for_pie(new_ev)
      #   end
      #   end_at = starts_at
      # elsif end_at < e.starts_at
      #   new_ev = { :title => '', :description => '', starts_at: end_at, ends_at: e.starts_at, color: 'transparent' }
      #   events << build_event_for_pie(new_ev)
      # elsif end_at > e.starts_at
      #   e.starts_at = end_at
      # end
      #
      # end_at = e.ends_at

      # events << build_event_for_pie(e)
    # }
    # if end_at < ends_at
    #   new_ev = { :title => '', :description => '', starts_at: end_at, ends_at: ends_at, color: 'transparent' }
    #   events << build_event_for_pie(new_ev)
    # end
    # events
  end

  def build_event_for_pie event
    days  = (event[:ends_at].to_date - event[:starts_at].to_date).to_i
    #binding.pry
    { id: event[:id].to_s, title: event[:title], icon: event[:icon], desc: event[:description], starts_at: event[:starts_at].strftime('%d/%m/%Y'), ends_at: event[:ends_at].strftime('%d/%m/%Y'), value: days, color: event[:color], text_color: event[:text_color], highlight: 'rgba(100,200,100,.3)' }
  end


  def build_timeline calendar_events
    events = [ ]
    calendar_events.all.map { |i|
      if i.ends_at
        action = i.ends_at > Date.today ? 'закінчиться: ' + i.ends_at.strftime('%d-%m-%Y') : 'закінчилась'
      else
        action = 'одноденна'
      end
      events << { id: i.id.to_s,  holder: i.holder, dt: i.starts_at, action: action, title: i.title, description: i.description, icon: i.icon, color: i.color, all_day: i.all_day }
    }

    # today = DateTime.now.strftime('%d-%m-%Y')
    # events << { dt: today } unless events.any? {|e| e[:dt] == today }

    events.sort_by { |m| m[:dt] }.reverse!
  end

  private

  def set_calendar
    @calendar = Calendar.find(params[:calendar_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def subscriber_params
    params.require(:subscriber).permit(:email)
  end
end
