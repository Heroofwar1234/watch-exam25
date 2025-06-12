defmodule JswatchWeb.ClockManager do
  use GenServer


  @change [:Day, :Month, :Year]

  def format_date(date, show, selection) do
    day = if date.day < 10, do: "0#{date.day}", else: "#{date.day}"
    month = ~w[ENE FEB MAR ABR MAY JUN JUL AGO SEP OCT NOV DIC] |> Enum.at(date.month - 1)
    year = date.year - 2000
    {day,month,year} =
      case selection do
        Day -> {(if show, do: day, else: "  "), month, year}
        Month -> {day, (if show, do: month, else: "   "), year}
        _ -> {day, month, (if show, do: year, else: "  ")}
      end
    "#{day}/#{month}/#{year}"
  end

  def init(ui) do
    :gproc.reg({:p, :l, :ui_event})
    {_, now} = :calendar.local_time()
    date = Date.utc_today()
    time = Time.from_erl!(now)
    alarm = Time.add(time, 10)
    Process.send_after(self(), :working_working, 1000)
    GenServer.cast(ui, {:set_time_display, Time.truncate(time, :second) |> Time.to_string })
    GenServer.cast(ui, {:set_date_display, format_date(date, true, Day) })
    {:ok, %{ui_pid: ui, time: time, date: date, alarm: alarm, st1: Working, st2: Idle, date_edit: false, selection: Day}}
  end   #Agregar Campos para parar y seleccionar campo para cambiar , default es day

  def handle_info(:working_working, %{ui_pid: ui, time: time, alarm: alarm, st1: Working} = state) do
    Process.send_after(self(), :working_working, 1000)
    time = Time.add(time, 1)
    if time == alarm do
      :gproc.send({:p, :l, :ui_event}, :start_alarm)
    end
    GenServer.cast(ui, {:set_time_display, Time.truncate(time, :second) |> Time.to_string })
    {:noreply, state |> Map.put(:time, time) }
  end

  def handle_info(_event, state), do: {:noreply, state}

  # Camviar a modo editar
  def handle_info(:"top-left-pressed", %{date_edit: false} = state) do
    GenServer.cast(state.ui_pid, {:set_date_display, format_date(state.date, true, Day)})
    {:noreply, %{state | date_edit: true, selection: Day}}
    #cambia date_edit a true
  end
   def handle_info(:"bottom-left-pressed", %{date_edit: true} = state) do
    GenServer.cast(state.ui_pid, {:set_date_display, format_date(state.date, true, Day)})
    {:noreply, %{state | date_edit: false}}
    #Cambia a falso

  end
#1
    # Ciclar campo por cambiar
  def handle_info(:"bottom-right-pressed", %{date_edit: true, selection: current} = state) do
    next = Enum.at(@change, rem(Enum.find_index(@change, &(&1 == current)) + 1, 3))
    GenServer.cast(state.ui_pid, {:set_date_display, format_date(state.date, true, next)})
    {:noreply, %{state | selection: next}}
  end

    # AGREGAR 1 a DAY
  def handle_info(:"top-right-pressed", %{date_edit: true, selection: Day, date: d} = state) do
    new_day = d.day + 1
    last = :calendar.last_day_of_the_month(d.year, d.month)
    new_date = %{d | day: if new_day > last, do: 1, else: new_day}
    GenServer.cast(state.ui_pid, {:set_date_display, format_date(new_date, true, Day)})
    {:noreply, %{state | date: new_date}}
  end

     # AGREGAR 1 a MONTH
  def handle_info(:"top-right-pressed", %{date_edit: true, selection: Month, date: d} = state) do
    new_month = rem(d.month, 12) + 1
    last = :calendar.last_day_of_the_month(d.year, new_month)
    new_day = min(d.day, last)
    new_date = %{d | month: new_month, day: new_day}
    GenServer.cast(state.ui_pid, {:set_date_display, format_date(new_date, true, Month)})
    {:noreply, %{state | date: new_date}}
  end

    # AGREGAR 1 a YEAR
  def handle_info(:"top-right-pressed", %{date_edit: true, selection: Year, date: d} = state) do
    new_date = %{d | year: d.year + 1}
    GenServer.cast(state.ui_pid, {:set_date_display, format_date(new_date, true, Year)})
    {:noreply, %{state | date: new_date}}
  end
end
