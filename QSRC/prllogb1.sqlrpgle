**Free
Ctl-Opt DftActGrp(*NO) Main(Main);

// Performance Logger

// This program write log entries to the PRLSST and PRLMPL tables. This is used
// to view system performance data


Dcl-Ds *n psds; //Pgm status DS
  psdsData       Char(429); // All data
  psdsPgmNam     Char(10)   OVERLAY(psdsData:001);  // Program name
  psdsJob        Char(26)   OVERLAY(psdsData:244);  // Qualififed Job name
End-Ds;

Dcl-S prlSstIdn int(20);
Dcl-S reset ind;
Dcl-C LOGINTERVAL const(300); // number of second to wait between log batches. 300 = 5 minutes

// Prototype for sleep, sleep for a number of seconds
Dcl-Pr Sleep Int(10) ExtPROC('sleep');
  seconds Uns(10) Value;
End-Pr;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

Dcl-Proc Main;

  // clean up old log records
  CleanUp();

  // Loop until program is ended
  DoU %shtdn();
    resetStatistics();

    // Sleep for specified interval
    Sleep(LOGINTERVAL);

    GenerateLogEntries();
  EndDo;

End-Proc;


// Clean up old log entries
Dcl-Proc CleanUp;

  // Only keep one entry per day for logs over a year old, do not keep any job entries over a year old
  Exec SQL
    Delete APLLIB.system_status_info_log
    Where prlSstIdn in (
      Select prlSstIdn
      From (
          Select
            prlSstIdn,
            row_Number() Over (Partition by date(create_time_stamp) Order by create_time_stamp desc) AS row_num
          From APLLIB.system_status_info_log
          Where create_time_stamp < current_date - 1 year
          )
      Where row_num <> 1
    );

  // Only keep one entry per hour for logs over 30 days old
  Exec SQL
    Delete APLLIB.system_status_info_log
    Where prlSstIdn in (
      Select prlSstIdn From (
        Select
          prlSstIdn,
          row_Number() Over (Partition by varchar_format(create_time_stamp, 'YYYY-MM-DD HH24')
                             Order by create_time_stamp desc) AS row_num
        From APLLIB.system_status_info_log
        Where create_time_stamp < current_date - 30 day
        )
      Where row_num <> 1
    );

  // Purge memory pool entries that no longer have a system status entry
  Exec SQL
    Delete APLLIB.memory_pool_info_log a
    Where a.prlMplIdn in (
      Select
        b.prlMplIdn
      From APLLIB.memory_pool_info_log b
      Exception Join APLLIB.system_status_info_log c on c.prlSstIdn = b.prlSstIdn
    );

  // Purge job status entries that no longer have a system status entry or are more than a year old
  Exec SQL
    Delete APLLIB.job_status_info_log
    Where crtDtm < current_date - 1 year;
  Exec SQL
    Delete APLLIB.job_status_info_log a
    Where a.prlJbsIdn in (
      Select
        b.prlJbsIdn
      From APLLIB.job_status_info_log b
      Exception Join APLLIB.system_status_info_log c on c.prlSstIdn = b.prlSstIdn
    );

End-Proc;


// log system status, memory pool status and active jobs.
Dcl-Proc GenerateLogEntries;

  // Add entry for system statistics, save id so the other logs can erferecne this as a batch
  Exec SQL
    Select prlSstIdn into :prlSstIdn from final table (
      Insert Into APLLIB.system_status_info_log (
        total_jobs_in_system, maximum_jobs_in_system, active_jobs_in_system, interactive_jobs_in_system,
        jobs_signed_on, jobs_disconnected, jobs_suspended_by_sysreq, jobs_suspended_by_group_job,
        jobs_print_waiting, batch_running, batch_waiting_to_run, batch_ending, batch_message_wait,
        batch_held_while_running, batch_held_on_jobq, batch_on_held_jobq, batch_on_unassigned_jobq,
        batch_print_waiting, elapsed_time, elapsed_cpu_used, elapsed_cpu_shared, elapsed_cpu_uncapped_capacity,
        configured_cpus, cpu_sharing_attribute, current_cpu_capacity, average_cpu_rate, average_cpu_utilization,
        minimum_cpu_utilization, maximum_cpu_utilization, sql_cpu_utilization, main_storage_size, system_asp_storage,
        total_auxiliary_storage, system_asp_used, current_temporary_storage, maximum_temporary_storage_used,
        permanent_address_rate, temporary_address_rate, temporary_256mb_segments, temporary_4gb_segments,
        permanent_256mb_segments, permanent_4gb_segments, temporary_job_structures_available,
        permanent_job_structures_available, total_job_table_entries, available_job_table_entries,
        in_use_job_table_entries, active_job_table_entries, jobq_job_table_entries, outq_job_table_entries,
        joblog_pending_job_table_entries, host_name, partition_id, number_of_partitions, active_threads_in_system,
        restricted_state, partition_name,
        partition_group_id, shared_processor_pool_id, defined_memory,
        minimum_memory, maximum_memory, memory_increment, dedicated_processors, physical_processors,
        physical_processors_shared_pool, maximum_physical_processors, defined_virtual_processors, virtual_processors,
        minimum_virtual_processors, maximum_virtual_processors, defined_processing_capacity, processing_capacity,
        unallocated_processing_capacity, minimum_required_processing_capacity, maximum_licensed_processing_capacity,
        minimum_processing_capacity, maximum_processing_capacity, processing_capacity_increment,
        defined_interactive_capacity, interactive_capacity, interactive_threshold, unallocated_interactive_capacity,
        minimum_interactive_capacity, maximum_interactive_capacity, defined_variable_capacity_weight,
        variable_capacity_weight, unallocated_variable_capacity_weight, hardware_multithreading,
        bound_hardware_threads, threads_per_processor, dispatch_latency, dispatch_wheel_rotation_time,
        total_cpu_time, interactive_cpu_time, interactive_cpu_time_above_threshold, unused_cpu_time_shared_pool,
        machine_type, machine_model, serial_number, machine_serial_number, attention_light, ipl_mode, ipl_type,
        journal_recovery_count, journal_cache_wait_time, job_schedule_status, access_path_target_recovery_time,
        smapp_include_access_paths, access_path_estimated_recovery_time,
        access_path_estimated_ineligible_recovery_time, smapp_disk_storage_used, power_enterprise_pool_processors,
        create_time_stamp, create_user, create_job, create_program,
        maintenance_time_stamp, maintenance_user, maintenance_job, maintenance_program
      )
      Select
        total_jobs_in_system, maximum_jobs_in_system, active_jobs_in_system, interactive_jobs_in_system,
        jobs_signed_on, jobs_disconnected, jobs_suspended_by_sysreq, jobs_suspended_by_group_job,
        jobs_print_waiting, batch_running, batch_waiting_to_run, batch_ending, batch_message_wait,
        batch_held_while_running, batch_held_on_jobq, batch_on_held_jobq, batch_on_unassigned_jobq,
        batch_print_waiting, elapsed_time, elapsed_cpu_used, elapsed_cpu_shared, elapsed_cpu_uncapped_capacity,
        configured_cpus, cpu_sharing_attribute, current_cpu_capacity, average_cpu_rate, average_cpu_utilization,
        minimum_cpu_utilization, maximum_cpu_utilization, sql_cpu_utilization, main_storage_size, system_asp_storage,
        total_auxiliary_storage, system_asp_used, current_temporary_storage, maximum_temporary_storage_used,
        permanent_address_rate, temporary_address_rate, temporary_256mb_segments, temporary_4gb_segments,
        permanent_256mb_segments, permanent_4gb_segments, temporary_job_structures_available,
        permanent_job_structures_available, total_job_table_entries, available_job_table_entries,
        in_use_job_table_entries, active_job_table_entries, jobq_job_table_entries, outq_job_table_entries,
        joblog_pending_job_table_entries, host_name, partition_id, number_of_partitions, active_threads_in_system,
        restricted_state, cast(partition_name as varchar(256) ccsid 37),
        partition_group_id, shared_processor_pool_id, defined_memory,
        minimum_memory, maximum_memory, memory_increment, dedicated_processors, physical_processors,
        physical_processors_shared_pool, maximum_physical_processors, defined_virtual_processors, virtual_processors,
        minimum_virtual_processors, maximum_virtual_processors, defined_processing_capacity, processing_capacity,
        unallocated_processing_capacity, minimum_required_processing_capacity, maximum_licensed_processing_capacity,
        minimum_processing_capacity, maximum_processing_capacity, processing_capacity_increment,
        defined_interactive_capacity, interactive_capacity, interactive_threshold, unallocated_interactive_capacity,
        minimum_interactive_capacity, maximum_interactive_capacity, defined_variable_capacity_weight,
        variable_capacity_weight, unallocated_variable_capacity_weight, hardware_multithreading,
        bound_hardware_threads, threads_per_processor, dispatch_latency, dispatch_wheel_rotation_time,
        total_cpu_time, interactive_cpu_time, interactive_cpu_time_above_threshold, unused_cpu_time_shared_pool,
        machine_type, machine_model, serial_number, machine_serial_number, attention_light, ipl_mode, ipl_type,
        journal_recovery_count, journal_cache_wait_time, job_schedule_status, access_path_target_recovery_time,
        smapp_include_access_paths, access_path_estimated_recovery_time,
        access_path_estimated_ineligible_recovery_time, smapp_disk_storage_used, power_enterprise_pool_processors,
        current_timestamp, user, :psdsJob, :psdsPgmNam,
        current_timestamp, user, :psdsJob, :psdsPgmNam
      From Table(QSYS2.SYSTEM_STATUS(reset_statistics=>'NO'))
    );

  // Log entry for memory pools
  Exec SQL
    Insert Into APLLIB.memory_pool_info_log (
      prlSstIdn,
      system_pool_id, pool_name, current_size, reserved_size, defined_size, maximum_active_threads,
      current_threads, current_ineligible_threads, subsystem_library_name, subsystem_name,
      description, paging_option, elapsed_time, elapsed_database_faults, elapsed_non_database_faults,
      elapsed_total_faults, elapsed_database_pages, elapsed_non_database_pages, elapsed_active_to_wait,
      elapsed_wait_to_ineligible, elapsed_active_to_ineligible, tuning_priority, tuning_minimum_size,
      tuning_maximum_size, tuning_minimum_faults, tuning_maximum_faults, tuning_thread_faults,
      tuning_minimum_activity, tuning_maximum_activity,
      create_time_stamp, create_user, create_job, create_program,
      maintenance_time_stamp, maintenance_user, maintenance_job, maintenance_program
    )
    Select
      :prlSstIdn,
      system_pool_id, pool_name, current_size, reserved_size, defined_size, maximum_active_threads,
      current_threads, current_ineligible_threads, subsystem_library_name, subsystem_name,
      description, paging_option, elapsed_time, elapsed_database_faults, elapsed_non_database_faults,
      elapsed_total_faults, elapsed_database_pages, elapsed_non_database_pages, elapsed_active_to_wait,
      elapsed_wait_to_ineligible, elapsed_active_to_ineligible, tuning_priority, tuning_minimum_size,
      tuning_maximum_size, tuning_minimum_faults, tuning_maximum_faults, tuning_thread_faults,
      tuning_minimum_activity, tuning_maximum_activity,
      current_timestamp, user, :psdsJob, :psdsPgmNam,
      current_timestamp, user, :psdsJob, :psdsPgmNam
    From Table(QSYS2.MEMORY_POOL(reset_statistics=>'NO'))
    Where current_size <> 0 or defined_size <> 0 or description is not null;

  // Log active jobs
  Exec SQL
    Insert Into APLLIB.job_status_info_log (
      prlSstIdn,
      job_name, job_name_short, job_user, job_number, internal_job_id, subsystem, subsystem_library_name,
      authorization_name, job_type, function_type, function_name, job_status, memory_pool, run_priority, thread_count,
      temporary_storage, cpu_time, total_disk_io_count, elapsed_time, elapsed_interaction_count,
      elapsed_total_response_time, elapsed_total_disk_io_count, elapsed_async_disk_io_count,
      elapsed_sync_disk_io_count, elapsed_cpu_percentage, elapsed_cpu_time, elapsed_page_fault_count,
      server_type, job_description_library, job_description, job_queue_library, job_queue,
      sort_sequence_library, sort_sequence, job_type_enhanced, job_entered_system_time, job_active_time,
      client_ip_address, job_user_identity_setting, job_user_identity, signal_status, message_reply,
      maximum_active_threads, system_pool_id, pool_name, qtemp_size, peak_temporary_storage, default_wait,
      maximum_processing_time_allowed, maximum_temporary_storage_allowed, time_slice, page_faults,
      total_response_time, interactive_transactions, database_lock_waits, non_database_lock_waits,
      internal_machine_lock_waits, database_lock_wait_time, non_database_lock_wait_time,
      internal_machine_lock_wait_time, sql_statement_text, sql_statement_status, sql_statement_start_timestamp,
      sql_statement_name, sql_statement_library_name, sql_statement_object_name, sql_statement_object_type,
      query_options_library_name, sql_activation_group_count, sql_descriptor_count, sql_lob_locator_count,
      cli_handle_count, sql_server_mode, client_acctng, client_applname, client_programid, client_userid,
      client_wrkstnname, routine_type, routine_schema, routine_specific_name, client_port, client_host,
      interface_name, interface_type, interface_level, server_mode_connecting_job, server_mode_connecting_thread,
      prestart_job_reuse_count, prestart_job_max_use_count, available_result_sets, unconsumed_result_sets,
      open_cursor_count, full_open_cursor_count, pseudo_open_cursor_count, pseudo_closed_cursor_count,
      largest_query_size, open_files,
      create_time_stamp, create_user, create_job, create_program,
      maintenance_time_stamp, maintenance_user, maintenance_job, maintenance_program
    )
    Select
      :prlSstIdn,
      job_name, job_name_short, job_user, job_number, internal_job_id, subsystem, subsystem_library_name,
      authorization_name, job_type, function_type, function, job_status, memory_pool, run_priority, thread_count,
      temporary_storage, cpu_time, total_disk_io_count, elapsed_time, elapsed_interaction_count,
      elapsed_total_response_time, elapsed_total_disk_io_count, elapsed_async_disk_io_count,
      elapsed_sync_disk_io_count, elapsed_cpu_percentage, elapsed_cpu_time, elapsed_page_fault_count,
      server_type, job_description_library, job_description, job_queue_library, job_queue,
      sort_sequence_library, sort_sequence, job_type_enhanced, job_entered_system_time, job_active_time,
      client_ip_address, job_user_identity_setting, job_user_identity, signal_status, message_reply,
      maximum_active_threads, system_pool_id, pool_name, qtemp_size, peak_temporary_storage, default_wait,
      maximum_processing_time_allowed, maximum_temporary_storage_allowed, time_slice, page_faults,
      total_response_time, interactive_transactions, database_lock_waits, non_database_lock_waits,
      internal_machine_lock_waits, database_lock_wait_time, non_database_lock_wait_time,
      internal_machine_lock_wait_time, sql_statement_text, sql_statement_status, sql_statement_start_timestamp,
      sql_statement_name, sql_statement_library_name, sql_statement_object_name, sql_statement_object_type,
      query_options_library_name, sql_activation_group_count, sql_descriptor_count, sql_lob_locator_count,
      cli_handle_count, sql_server_mode, client_acctng, client_applname, client_programid, client_userid,
      client_wrkstnname, routine_type, routine_schema, routine_specific_name, client_port, client_host,
      interface_name, interface_type, interface_level, server_mode_connecting_job, server_mode_connecting_thread,
      prestart_job_reuse_count, prestart_job_max_use_count, available_result_sets, unconsumed_result_sets,
      open_cursor_count, full_open_cursor_count, pseudo_open_cursor_count, pseudo_closed_cursor_count,
      largest_query_size, open_files,
      current_timestamp, user, :psdsJob, :psdsPgmNam,
      current_timestamp, user, :psdsJob, :psdsPgmNam
    From Table(QSYS2.ACTIVE_JOB_INFO(reset_statistics=>'NO'));

End-Proc;


Dcl-Proc resetStatistics;

  Exec SQL Select max('1') into :reset From Table(QSYS2.SYSTEM_STATUS(reset_statistics=>'YES'));
  Exec SQL Select max('1') into :reset From Table(QSYS2.MEMORY_POOL(reset_statistics=>'YES'));
  Exec SQL Select max('1') into :reset FROM TABLE (QSYS2.ACTIVE_JOB_INFO(reset_statistics=>'YES'));

End-Proc;
