##### TODO: review this utility and clean up

import sys
import numpy as np
import pandas as pd
import prismatui as pr

UNIQUENESS_TRESHOLD = 80

PALETTE = {
    "colors": [
        (  0,     0,    0), ( 680,    0,    0), (   0,  680,    0),
        (680,   680,    0), (   0,    0,  680), ( 680,    0,  680),
        (  0,   680,  680), ( 680,  680,  680), ( 678,  847,  901),
        (  0,   749, 1000), ( 117,  564, 1000), ( 482,  407,  933),
        (541,   168,  886), ( 854,  439,  839), (1000,    0, 1000),
        (1000,   78,  576), ( 690,  188,  376), ( 862,   78,  235),
        (941,   501,  501), (1000,  270,    0), ( 1000, 647,    0),
        (956,   643,  376), ( 941,  901,  549), ( 501,  501,    0),
        (1000, 1000,    0), ( 603,  803,  196), ( 486,  988,    0),
        (564,   933,  564), ( 560,  737,  560), ( 133,  545,  133),
        (  0,  1000,  498), (   0, 1000, 1000), (   0,  545,  545),
        (501,   501,  501),
    ],
    "pairs":  [
        [ 0, 0], [ 0, 1], [ 0, 2], [ 0, 3], [ 0, 4], [ 0, 5], [ 0, 6],
        [ 7, 0], [ 8, 0], [ 9, 0], [10, 0], [11, 0], [12, 0], [13, 0],
        [14, 0], [15, 0], [16, 0], [17, 0], [18, 0], [19, 0], [20, 0],
        [21, 0], [22, 0], [23, 0], [24, 0], [25, 0], [26, 0], [27, 0],
        [28, 0], [29, 0], [30, 0], [31, 0], [32, 0], [33, 0]
    ]
}


def pad_slice(s: str, width: int) -> str:
    return s.ljust(width)[:width]


class TUIPrismaCSV(pr.Terminal):
    COLUMN_WIDTH = 25

    def __init__(self, *paths_csv):
        super().__init__()
        self.paths_csv = [str(p) for p in paths_csv]

        self.idx_current_csv: int
        self.current_path_csv: str
        self.df: pd.DataFrame
        self._update_current_df(0)

        self.idx_col = 0
        self.idx_row = 0

        self.max_col_widths = [max(self.df[col].apply(len)) for col in self.df.columns]
        self.col_widths = [min(m,self.COLUMN_WIDTH) for m in self.max_col_widths]
        self.df_colors = self.df.copy()

        self.col_docolor = [True for _ in self.df.columns]


    def on_start(self):
        self.palette.load_dict(PALETTE)

        first_color = 7

        n_available_pairs = len(self.palette.palette["colors"]) - first_color
        unique_df_vals = [self.df[col].unique() for col in self.df.columns]

        val2color = {
            col : {val:first_color+(i%n_available_pairs) for i,val in enumerate(vals)}
            for col,vals in zip(self.df.columns, unique_df_vals)
        }

        for i,col in enumerate(self.df.columns):
            self.df_colors[col] = self.df[col].apply(lambda x: pr.get_color_pair(val2color[col][x]))
            self.col_docolor[i] = len(unique_df_vals[i]) < UNIQUENESS_TRESHOLD

        self.header = self.root.create_child(3, 1.0, 0, 0)
        self.body   = self.root.create_child(-4, 1.0, 3, 0)
        self.footer = self.root.create_child(1,1.0, -1, 0)



    def on_update(self):
        match self.key:
            case pr.KEY_UP:
                self.idx_row = max(0, self.idx_row - 1)

            case pr.KEY_DOWN:
                self.idx_row = min(self.idx_row + 1, len(self.df) - 1)

            case pr.KEY_LEFT:
                self.idx_col = max(0, self.idx_col - 1)

            case pr.KEY_RIGHT:
                self.idx_col = min(self.idx_col + 1, len(self.df.columns) - 1)

            case 43: # +
                self.col_widths[self.idx_col] = min(self.col_widths[self.idx_col] + 1, self.max_col_widths[self.idx_col])

            case 45: # -
                self.col_widths[self.idx_col] = max(0, self.col_widths[self.idx_col] - 1)

            case 112: # p
                self._update_current_df(max(0, self.idx_current_csv - 1))


            case 110: # n
                self._update_current_df(min(self.idx_current_csv + 1, len(self.paths_csv) - 1))
                pass


        rows_middle = self.body.h // 2
        start_row = max(0,self.idx_row-rows_middle)
        end_row   = start_row + self.body.h

        df = self.df.iloc[start_row:end_row, :].copy()

        adj_x = max(0, self._current_x() + self.col_widths[self.idx_col] - self.w)

        for w,col in zip(self.col_widths, df.columns):
            df[col] = df[col].apply(lambda s: pad_slice(s,w))

        str_header0_c = f"({self.w} cols, {self.h} rows)"
        max_len = max(0, self.w - len(str_header0_c))
        str_header0_a = f"[{self.current_path_csv[:max_len]}]"
        pad_len = max(0, max_len - len(str_header0_a))
        str_header0_b =  ' '*pad_len
        str_header0 = str_header0_a + str_header0_b + str_header0_c

        str_header1 = '│'.join(
            pad_slice(s,w) for w,s in zip(self.col_widths, self.df.columns)
        )[adj_x:]


        str_separator = ('─'*len(str_header1)).ljust(self.w)

        str_header1 = str_header1.ljust(self.w)


        start_hlight = self._current_x() - adj_x
        end_hlight = start_hlight + self.col_widths[self.idx_col]


        chars_header = [str_header0, str_header1, str_separator]
        attrs_header = np.full((3,self.body.w), pr.A_BOLD)


        attrs_header[1, start_hlight:end_hlight] |= pr.A_REVERSE

        agg: pd.Series[str] = df.agg('│'.join, axis = 1)

        chars_body = list(agg.apply(lambda s: s[adj_x:]))

        attrs_body = np.full((len(agg), len(agg.iloc[0])), pr.A_NORMAL)

        x0 = 0
        x1 = 0
        for i,(w,col) in enumerate(zip(self.col_widths, self.df.columns)):
            x0 = x1
            x1 += w
            if x0 > self.body.w: continue
            if x1 < adj_x: continue

            if not self.col_docolor[i]: continue

            colors = self.df_colors.iloc[start_row:end_row, :][col]
            actual_w = len(attrs_body[0, x0+i:x1+i])
            attrs_body[:, x0+i:x1+i] = np.tile(colors,(actual_w,1)).T

        attrs_body = attrs_body[:, adj_x:]


        y_hlight = self.idx_row - start_row

        mask0 = np.zeros_like(attrs_body, dtype = bool)
        mask1 = np.zeros_like(attrs_body, dtype = bool)
        mask0[:, start_hlight:end_hlight] = True
        mask1[y_hlight, :] = True

        attrs_body[mask0 ^ mask1] |= pr.A_REVERSE


        self.header.draw_matrix(0,0,chars_header,attrs_header)
        self.body.draw_matrix(0,0,chars_body, attrs_body)
        self.footer.draw_text(0, 0, "Press F1 to exit", pr.get_color_pair(6))

    def should_stop(self):
        return self.key == pr.KEY_F1


    def _current_x(self):
         return sum(self.col_widths[:self.idx_col]) + self.idx_col

    def _update_current_df(self, idx: int):
        self.idx_current_csv = idx
        self.current_path_csv = self.paths_csv[idx]
        self.df = pd.read_csv(self.current_path_csv).astype(str)


if __name__ == "__main__":
    PATHS_CSV = sys.argv[1:]
    t = TUIPrismaCSV(*PATHS_CSV)
    t.run()

    ##### TODO:
    # figure out what to do with very long columns that span more width than self.body.w
    # include the header into the "max_col_widths"
    # apply the UNIQUENESS_TRESHOLD
    # apply colors differently to number columns (e.g. by sorted value or by following some scale)
    # be able to edit the current cell?
    # be able to open multiple csv files simultaneously and cycle through them.
    # display the current file on the header and the number of rows,cols

    ###### old palette
    # PALETTE = {"colors": [[0, 0, 0], [680, 0, 0], [0, 680, 0], [680, 680, 0], [0, 0, 680], [680, 0, 680], [0, 680, 680], [680, 680, 680], [678, 847, 901], [0, 749, 1000], [117, 564, 1000], [0, 0, 1000], [0, 0, 545], [282, 239, 545], [482, 407, 933], [541, 168, 886], [501, 0, 501], [854, 439, 839], [1000, 0, 1000], [1000, 78, 576], [690, 188, 376], [862, 78, 235], [941, 501, 501], [1000, 270, 0], [1000, 647, 0], [956, 643, 376], [941, 901, 549], [501, 501, 0], [545, 270, 74], [1000, 1000, 0], [603, 803, 196], [486, 988, 0], [564, 933, 564], [560, 737, 560], [133, 545, 133], [0, 1000, 498], [0, 1000, 1000], [0, 545, 545], [501, 501, 501]], "pairs": [[0, 0], [0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [7, 0], [8, 0], [9, 0], [10, 0], [11, 0], [12, 0], [13, 0], [14, 0], [15, 0], [16, 0], [17, 0], [18, 0], [19, 0], [20, 0], [21, 0], [22, 0], [23, 0], [24, 0], [25, 0], [26, 0], [27, 0], [28, 0], [29, 0], [30, 0], [31, 0], [32, 0], [33, 0], [34, 0], [35, 0], [36, 0], [37, 0], [38, 0]]}
