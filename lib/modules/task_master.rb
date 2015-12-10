module TaskMaster

  def pids_directory_path
    "#{Rails.root}/tmp/pids"
  end


  def add_task_pid(task_name)
    pid_path = get_pid_path(task_name)
    # deploy_user_id = `id -u deploy`.strip.to_i

    if !File.exist?(pid_path)
      if !Dir.exist?(pids_directory_path)
        Dir.mkdir(pids_directory_path)
      end
      pid_file = File.new(pid_path,"w")

      pid = Process.pid
      Rails.logger.info "Adding pid file for process: #{ pid }"
      pid_file << pid

      # File.chown(deploy_user_id,deploy_user_id,pid_path)
      pid_file.close
      Rails.logger.info "PID file added: #{ pid_path }"
      true
    else
      pid = get_pid(task_name)
      if pid && pid.length > 0 && !process_status(pid)
        remove_task_pid(task_name)
        add_task_pid(task_name)
      else
        nil
      end
    end
  end


  def remove_task_pid(task_name)
    pid_path = get_pid_path(task_name)

    if File.exist?(pid_path)
      # pid = get_pid(task_name)
      File.delete(pid_path)
      Rails.logger.info "PID file removed: #{ pid_path }"
    end
  end


  def get_pid_path(task_name)
    "#{pids_directory_path}/#{task_name}.pid"
  end


  def get_pid(task_name)
    pid_path = get_pid_path(task_name)
    pid = nil
    if File.exist?(pid_path)
      pid = File.read(pid_path)
    end
    pid
  end


  def process_status(pid)
    status = `ps -o state --no-headers #{ pid }`
    return status.empty? ? nil : status
  end


  def clear_all_pids

    if Dir.exist?(pids_directory_path)
      Dir.entries(pids_directory_path).each do |f|
        if f.match(/\.pid$/)
          task_name = f.gsub(/\.pid/,'')
          remove_task_pid(task_name)
        end
      end
    end
  end

end
