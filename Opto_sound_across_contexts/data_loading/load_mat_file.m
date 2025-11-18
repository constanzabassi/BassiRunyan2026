function data = load_mat_file(path, filename)
    loaded = load(fullfile(path, filename));
    data = loaded.(char(fieldnames(loaded)));
end