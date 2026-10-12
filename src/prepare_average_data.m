function [lab_sig, wild_sig] = prepare_average_data(fs, segment_time, data_dir, ...
        lab_files, wild_files, do_norm, age_label, out_path)
%PREPARE_AVERAGE_DATA  Average EEG recordings into one signal per group.
%   Each recording (CSV, columns 2-5 = four EEG channels) is cut into
%   non-overlapping segments of SEGMENT_TIME seconds. The segments are
%   averaged within each mouse, and the per-mouse averages are then
%   averaged across the group.
%
%   Returns [segment samples x 4] matrices for the 5xFAD (lab) and
%   wild-type groups, and saves them to OUT_PATH.

    seg_len = round(segment_time * fs);

    lab_sig  = average_group(data_dir, lab_files,  seg_len, do_norm, ['5xFAD ' age_label]);
    wild_sig = average_group(data_dir, wild_files, seg_len, do_norm, ['wild ' age_label]);

    plot_group_means(lab_sig(:, 1), wild_sig(:, 1), age_label);
    save(out_path, 'lab_sig', 'wild_sig');
end


function group_sig = average_group(data_dir, files, seg_len, do_norm, group_name)
    n_mice = numel(files);
    group_sig = zeros(seg_len, 4);
    figure('Name', ['Channel 1 per mouse - ' group_name]);

    for k = 1:n_mice
        tbl = readtable(fullfile(data_dir, files{k}));
        eeg = tbl{:, 2:5};                            % four EEG channels
        if do_norm
            eeg = (eeg - mean(eeg)) ./ std(eeg);      % z-score each channel
        end

        subplot(ceil(n_mice / 2), 2, k);
        plot(eeg(:, 1));
        title(files{k}, 'Interpreter', 'none');
        xlabel('sample');
        ylabel('amplitude');
        fprintf('%s: ch1 mean = %.2f, std = %.2f\n', files{k}, mean(eeg(:, 1)), std(eeg(:, 1)));

        % average the non-overlapping segments of this recording
        starts = 1:seg_len:size(eeg, 1) - seg_len;
        mouse_avg = zeros(seg_len, 4);
        for s = starts
            mouse_avg = mouse_avg + eeg(s:s + seg_len - 1, :);
        end
        group_sig = group_sig + mouse_avg / numel(starts);
    end

    group_sig = group_sig / n_mice;
end


function plot_group_means(lab_ch1, wild_ch1, age_label)
% Plots on a fixed figure with hold on, so running both ages overlays 4m and 6m.
    figure(1000);
    set(gcf, 'Name', 'Average signal, 4m vs. 6m');
    hold on;
    if strcmp(age_label, '6m')
        colors = {'b', 'r'};
    else
        colors = {'c', 'g'};
    end
    plot(lab_ch1,  colors{1}, 'DisplayName', ['5xFAD ' age_label]);
    plot(wild_ch1, colors{2}, 'DisplayName', ['wild ' age_label]);
    add_mean_line(lab_ch1,  ['5xFAD ' age_label], 'top');
    add_mean_line(wild_ch1, ['wild ' age_label],  'bottom');
    legend('show');
    title('Average signal (channel 1), 4m vs. 6m');
    xlabel('sample');
end


function add_mean_line(x, name, valign)
    label = sprintf('%s mean = %.2f \\pm %.2f', name, mean(x), std(x));
    yline(mean(x), 'k--', label, 'LineWidth', 2, ...
        'LabelVerticalAlignment', valign, 'HandleVisibility', 'off');
end
