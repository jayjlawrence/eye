module Eye::Process::Controller

  def send_command(command)
    schedule command
  end

  def start
    if set_pid_from_file
      if process_realy_running?
        info "process from pid_file(#{self.pid}) found and already running, so :up"
        switch :already_running
        :ok
      else
        info "pid_file found, but process in pid_file(#{self.pid}) not found, starting..."
        start_process
      end
    else
      info 'pid_file not found, so starting process...'
      start_process
    end
  end

  def stop
    stop_process
    switch :unmonitoring
  end

  def restart
    restart_process
  end

  def monitor
    if self[:auto_start]
      start
    else
      if try_update_pid_from_file
        info "process from pid_file(#{self.pid}) found and already running, so :up"
        switch :already_running
      else
        warn "process not found, so :unmonitor"
        schedule :unmonitor
      end
    end
  end

  def unmonitor
    switch :unmonitoring
  end
  
  def remove
    if self[:stop_on_remove]
      info 'process has stop_on_remove option, so sync-stop it first'
      stop
    end

    remove_watchers
    remove_childs
    remove_triggers

    self.terminate
  end
  
end