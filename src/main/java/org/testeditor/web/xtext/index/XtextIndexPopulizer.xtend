package org.testeditor.web.xtext.index

import java.io.File
import org.eclipse.emf.common.util.URI

class XtextIndexPopulizer {
	
	/**
	 * redefine to match only files of your languages to be added to the index
	 */
	def boolean isIndexRelevant(File file) {
		return true
	}
	
	def void populizeWithRepo(XtextIndex index, File file) {
		file.listFiles?.forEach[
			populizeWithRepo(index, it)
		]
		if (file.isFile && isIndexRelevant(file)) {
			index.add(URI.createFileURI(file.absolutePath))
		}
	}
	
}