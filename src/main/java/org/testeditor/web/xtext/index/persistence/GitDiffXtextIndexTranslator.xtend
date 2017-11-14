package org.testeditor.web.xtext.index.persistence

import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.jgit.diff.DiffEntry
import org.testeditor.web.xtext.index.XtextIndex
import org.slf4j.LoggerFactory

class GitDiffXtextIndexTranslator {

	protected static val logger = LoggerFactory.getLogger(GitDiffXtextIndexTranslator)

	/**
	 * update the index according to the git diff entries passed
	 */
	def void execute(List<DiffEntry> gitDiffs, XtextIndex index) {
		if (index !== null) {
			gitDiffs.forEach [
				switch (changeType) {
					case ADD: {
						logger.info('''Adding file='«newPath»' to index based on changeType='«changeType.name»'.''')
						index.add(URI.createFileURI(newPath))
					}
					case COPY: {
						logger.info('''Adding file='«newPath»' to index based on changeType='«changeType.name»'.''')
						index.add(URI.createFileURI(newPath))
					}
					case DELETE: {
						logger.info('''Removing file='«oldPath»' from index based on changeType='«changeType.name»'.''')
						index.remove(URI.createFileURI(oldPath))
					}
					case MODIFY: {
						logger.info('''Updating file='«oldPath»' within index based on changeType='«changeType.name»'.''')
						index.update(URI.createFileURI(oldPath))
					}
					case RENAME: {
						logger.info('''Removing file='«oldPath»' index, adding same file='«newPath»' based on changeType='«changeType.name»'.''')
						index.remove(URI.createFileURI(oldPath))
						index.add(URI.createFileURI(newPath))
					}
					default:
						throw new RuntimeException('''Unknown git diff change type='«changeType.name»'.''')
				}
			]
		} else {
			logger.error('xtext index not present.')
		}
	}

}
