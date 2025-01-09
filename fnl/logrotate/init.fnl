(local default_config {; target file paths: string[]
                       :targets []
                       ; logrotate-nvim config path: string
                       :config_path (.. (vim.fn.stdpath :data) :/logrotate)
                       ; rotate inverval: "daily" | "weekly" | "monthly"
                       :interval :weekly})

(local encode vim.fn.json_encode)
(local decode vim.fn.json_decode)
(local group (vim.api.nvim_create_augroup :logrotate {:clear true}))

; precondition: path is normalized
(fn dir? [path]
  (-?> (vim.uv.fs_stat path)
       (. type)
       (= :directory)))

(fn rotate? [interval t1 t2]
  (let [diff (math.abs (- t1 t2))]
    (case interval
      :daily (> diff 86400)
      :weekly (> diff 604800)
      :monthly (> diff 2592000)
      _ (error (.. "Unknown interval: " interval)))))

; precondition: path is normalized
(fn rotate [path]
  (let [name (vim.fn.fnamemodify path ":t:r")
        ext (vim.fn.fnamemodify path ":e")
        dir (vim.fn.fnamemodify path ":h")
        timestamp (os.date "%Y%m%d")
        new_path (.. dir "/" name "_" timestamp "." ext)]
    (os.rename path new_path)))

; precondition: path is normalized
(fn load_timestamps [path]
  (case (io.open path :r)
    fp (decode (fp:read :*a))
    _ {}))

; precondition: path is normalized
(fn save_timestamps [path timestamps]
  (doto (io.open path :w)
    (: :write (encode timestamps))
    (: :close)))

(fn setup [opt]
  (let [opt (vim.tbl_deep_extend :force default_config (or opt {}))
        timestamps_path (.. (vim.fn.expand opt.config_path) :/timestamps.json)
        callback (fn []
                   (let [timestamps (load_timestamps timestamps_path)]
                     (: (vim.iter opt.targets) :each
                        (fn [target]
                          (let [target (vim.fn.expand target)
                                now (os.time)
                                timestamp (or (?. timestamps target) now)]
                            (if (rotate? opt.interval timestamp now)
                                (do
                                  (rotate target)
                                  (tset timestamps target now))
                                (tset timestamps target timestamp)))))
                     (save_timestamps timestamps_path timestamps)))]
    ;; setup directory if needed
    (let [path (vim.fn.expand opt.config_path)]
      (if (not (dir? path))
          (vim.uv.fs_mkdir path 493)))
    ;; create autocmd
    (vim.api.nvim_create_autocmd [:VimLeave] {: group : callback})))

{: setup}
