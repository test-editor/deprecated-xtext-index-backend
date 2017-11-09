package org.testeditor.web.xtext.index

import java.io.File
import org.eclipse.emf.common.util.URI
import org.slf4j.LoggerFactory

class FileBasedXtextIndexFiller {
	
	protected static var logger = LoggerFactory.getLogger(FileBasedXtextIndexFiller)
	
	/**
	 * redefine to match only files of your languages to be added to the index
	 */
	def boolean isIndexRelevant(File file) {
		// TODO loop over registered languages and use extensions defined
		return #[".tsl",".tcl",".tml",".aml", ".config"].exists[file.name.endsWith(it)]
	}
	
	def void fillWithFileRecursively(XtextIndex index, File file) {
		file.listFiles?.forEach[
			fillWithFileRecursively(index, it)
		]
		if (file.isFile && file.isIndexRelevant) {
			logger.info("adding file '{}' to index", file.name)
			index.add(URI.createFileURI(file.absolutePath))
		}
	}
	
}
