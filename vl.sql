SELECT
    t1.eqp_id,
    t1.data_create_time,
    t1.line_no,
    t1.eqp_index,
    t1.step_seq,
    t1.process_id,
    t1.part_id,
    t1.ppid,
    t1.recipe_id,
    t1.trace_param_index,
    t1.param_item,
    t1.root_lot_id,
    t1.lot_id,
    t1.wafer_no,
    t1.line_id,
    t1.eqp_area,
    t1.fdc_model,
    t1.parents_eqp_id,
    t1.unit_index,
    t1.unit_name,
    t1.unit_type,
    t1.proc_module_type,
    t1.fdc_bin,
    t1.fdc_bin_prop,
    t1.param_id,
    t1.trace_param_name,
    t1.subitem,
    t1.measuretype_id,
    t1.priority,
    t1.is_trace_framing,
    t1.slot_no,
    (vl_not_nan / allcount) AS vl_per_nan,
    arrvl
FROM
    (
        SELECT
            eqp_id,
            data_create_time,
            line_no,
            eqp_index,
            step_seq,
            process_id,
            part_id,
            ppid,
            recipe_id,
            trace_param_index,
            param_item,
            root_lot_id,
            lot_id,
            wafer_no,
            line_id,
            eqp_area,
            fdc_model,
            parents_eqp_id,
            unit_index,
            unit_name,
            unit_type,
            proc_module_type,
            fdc_bin,
            fdc_bin_prop,
            param_id,
            trace_param_name,
            subitem,
            measuretype_id,
            priority,
            is_trace_framing,
            slot_no,
            Count(*) AS allcount,
            Count_if (vl <> 'NaN') AS vl_not_nan,
            count_if (vl = = 'NaN')
        FROM
            tv
        GROUP BY
            eqp_id,
            data_create_time,
            line_no,
            eqp_index,
            step_seq,
            process_id,
            part_id,
            ppid,
            recipe_id,
            trace_param_index,
            param_item,
            root_lot_id,
            lot_id,
            wafer_no,
            line_id,
            eqp_area,
            fdc_model,
            parents_eqp_id,
            unit_index,
            unit_name,
            unit_type,
            proc_module_type,
            fdc_bin,
            fdc_bin_prop,
            param_id,
            trace_param_name,
            subitem,
            measuretype_id,
            priority,
            is_trace_framing,
            slot_no
    ) AS t1,
    (
        SELECT
            eqp_id,
            data_create_time,
            line_no,
            eqp_index,
            step_seq,
            process_id,
            part_id,
            ppid,
            recipe_id,
            trace_param_index,
            param_item,
            root_lot_id,
            lot_id,
            wafer_no,
            line_id,
            eqp_area,
            fdc_model,
            parents_eqp_id,
            unit_index,
            unit_name,
            unit_type,
            proc_module_type,
            fdc_bin,
            fdc_bin_prop,
            param_id,
            trace_param_name,
            subitem,
            measuretype_id,
            priority,
            is_trace_framing,
            slot_no,
            sort_array (array_agg (all vl)) AS arrvl
        FROM
            tv
        GROUP BY
            eqp_id,
            data_create_time,
            line_no,
            eqp_index,
            step_seq,
            process_id,
            part_id,
            ppid,
            recipe_id,
            trace_param_index,
            param_item,
            root_lot_id,
            lot_id,
            wafer_no,
            line_id,
            eqp_area,
            fdc_model,
            parents_eqp_id,
            unit_index,
            unit_name,
            unit_type,
            proc_module_type,
            fdc_bin,
            fdc_bin_prop,
            param_id,
            trace_param_name,
            subitem,
            measuretype_id,
            F priority,
            is_trace_framing,
            slot_no
    ) AS t2
WHERE
    t1.eqp_id = t2.eqp_id
    and t1.data_create_time = t2.data_create_time
    and t1.line_no = t2.line_no
    and t1.eqp_index = t2.eqp_index
    and t1.step_seq = t2.step_seq
    and t1.process_id = t2.process_id
    and t1.part_id = t2.part_id
    and t1.ppid = t2.ppid
    and t1.recipe_id = t2.recipe_id
    and t1.trace_param_index = t2.trace_param_index
    and t1.param_item = t2.param_item
    and t1.root_lot_id = t2.root_lot_id
    and t1.lot_id = t2.lot_id
    and t1.wafer_no = t2.wafer_no
    and t1.line_id = t2.line_id
    and t1.eqp_area = t2.eqp_area
    and t1.fdc_model = t2.fdc_model
    and t1.parents_eqp_id = t2.parents_eqp_id
    and t1.unit_index = t2.unit_index
    and t1.unit_name = t2.unit_name
    and t1.unit_type = t2.unit_type
    and t1.proc_module_type = t2.proc_module_type
    and t1.fdc_bin = t2.fdc_bin
    and t1.fdc_bin_prop = t2.fdc_bin_prop
    and t1.param_id = t2.param_id
    and t1.trace_param_name = t2.trace_param_name
    and t1.subitem = t2.subitem
    and t1.measuretype_id = t2.measuretype_id
    and t1.priority = t2.priority
    and t1.is_trace_framing = t2.is_trace_framing
    and t1.slot_no = t2.slot_no
    and (vl_not_nan / allcount) > 0.95
LIMIT
    3