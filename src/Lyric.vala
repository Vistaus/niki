namespace niki {
    public class Lyric : Gee.TreeMap<int64?, string> {
        private struct Metadata {
            string tag;
            string info;
        }

        private Metadata [] metadata = {};
        private Gee.BidirMapIterator<int64?, string> lrc_iterator;
        private int offset = 0;

        public void add_metadata (string _tag, string _info) {
            metadata += Metadata () {
                tag = _tag,
                info = _info
            };
            if (_tag == "offset") {
                offset = int.parse (_info);
            }
        }

        public void add_line (int64 time, string text) {
            set (time, text);
        }

        private Gee.BidirMapIterator<int64?, string> iterator_get () {
            if (lrc_iterator == null || !lrc_iterator.valid) {
                lrc_iterator = bidir_map_iterator ();
                lrc_iterator.first ();
            }
            return lrc_iterator;
        }

        public int64 get_lyric_timestamp (int64 time_in_us, bool cur_pos = true) {
            var time_with_offset = time_in_us + offset;
            return iterator_lyric (time_with_offset, cur_pos).get_key ();
        }

        private Gee.BidirMapIterator<int64?, string> iterator_lyric (int64 time_in_us, bool cur_pos = true) {
            if (iterator_get ().get_key () > time_in_us) {
                iterator_get ().first ();
            }
            while (iterator_get ().get_key () < time_in_us && iterator_get ().has_next ()) {
                iterator_get ().next ();
            }
            if (cur_pos) {
                iterator_get ().previous ();
            }
            return iterator_get ();
        }

        public string to_string () {
            var builder = new StringBuilder ();
            builder.append (@"Metadata:\n");
            foreach (var data in metadata) {
                builder.append (@"$(data.tag) = ");
                builder.append (@"$(data.info)\n");
            }
            builder.append (@"Lyric:\n");
            this.foreach ((item) => {
                builder.append (@"$(item.key) : $(item.value)\n");
                return true;
            });
            return builder.str;
        }
    }
}
