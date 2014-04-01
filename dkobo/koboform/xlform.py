import re

select_qtypes = ["select_one (\w+)"]

class Xlform(object):
    """
    A class intended to add some basic manipulation to the shrunk CSV
    representation of the XLSForm.
    
    First pass is just intended to trim down the choice list to a reasonable size.
    Quick and dirty.
    """
    def __init__(self, csv):
        self._csv = csv
        self._rows = self._csv.split("\n")
        cols = self._rows[1].split(",")
        lists_to_keep = []
        first_list_name = False
        for qtype_re in select_qtypes:
            srch = re.search(qtype_re, self._rows[2])
            if srch:
                if not first_list_name:
                    first_list_name = srch.groups()[0]
                lists_to_keep.append(srch.groups()[0])
        lists_to_keep = set(lists_to_keep)
        if len(lists_to_keep) == 0:
            output_rows = self._rows[0:3]
        else:
            output_rows = self._rows[0:5]
            remaining_rows = self._rows[5:]
            for row in remaining_rows:
                add_me = False
                for list_name in lists_to_keep:
                    if list_name in row:
                        add_me = True
                if add_me:
                    output_rows.append(row)
        self._shrunk = "\n".join(output_rows)
        self._first_list_name = first_list_name
