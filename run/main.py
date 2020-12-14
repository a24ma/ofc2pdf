#!/usr/bin/env python3

import comtypes.client
import pathlib
import PyPDF2
from logging import getLogger
import aoutil as ao
from aoutil import ts
import time


ao.ts()
ao.setup_simple_logger(level="INFO")
log = getLogger()


def convert(in_file, out_file):
    log.info(in_file)
    wdFormatPDF = 17
    word = None
    doc = None
    try:
        word = comtypes.client.CreateObject('Word.Application')
        doc = word.Documents.Open(in_file)
        doc.SaveAs(out_file, FileFormat=wdFormatPDF)
    finally:
        if word is not None:
            doc.Close()
        if doc is not None:
            word.Quit()


def pdf_merger(out_pdf, pdfs):
    merger = PyPDF2.PdfFileMerger()

    for pdf in pdfs:
        log.info(pdf)
        merger.append(pdf)

    merger.write(out_pdf)
    merger.close()


file_path = pathlib.Path('sample.docx').absolute()
pdfs = []

word_fname = str(file_path)
pdf_fname = str(file_path.with_suffix(".pdf"))
pdfs.append(pdf_fname)
convert(word_fname, pdf_fname)

pdf_merger(str(file_path.with_name("out.pdf")), pdfs)

ao.ts()
