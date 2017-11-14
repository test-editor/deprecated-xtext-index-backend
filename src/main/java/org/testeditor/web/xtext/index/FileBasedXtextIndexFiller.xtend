package org.testeditor.web.xtext.index

import java.io.File
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource

class FileBasedXtextIndexFiller {
	
	/**
	 * redefine to match only files of your languages to be added to the index
	 */
	def boolean isIndexRelevant(File file) {
		val knownLanguageExtensions = Resource.Factory.Registry.INSTANCE.extensionToFactoryMap.keySet
		return knownLanguageExtensions.exists[file.name.endsWith('''.«it»''')]
	}
	
	def void fillWithFileRecursively(XtextIndex index, File file) {
		file.listFiles?.forEach [
			fillWithFileRecursively(index, it)
		]
		if (file.isFile && file.isIndexRelevant) {
			index.add(URI.createFileURI(file.absolutePath))
		}
	}
	
}
