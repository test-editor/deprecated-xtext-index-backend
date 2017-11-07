package org.testeditor.web.xtext.index.persistence

import com.google.inject.Guice
import javax.inject.Inject
import org.eclipse.jgit.api.Git
import org.eclipse.jgit.junit.RepositoryTestCase
import org.eclipse.jgit.revwalk.RevCommit
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder

import static org.assertj.core.api.Assertions.assertThat
import org.eclipse.jgit.diff.DiffEntry.ChangeType
import org.junit.After

class GitServiceTest extends RepositoryTestCase {
	

	// @Rule public var tempFolder = new TemporaryFolder

	@Inject GitService gitService // class under test
	
	
	var Git git // filled by setup

	@Before
	def void setupTest() {
		super.setUp
		git = new Git(db)

		// setup class under test
		Guice.createInjector.injectMembers(this)
		gitService.initRepository(git.repository.directory.parentFile)
	}
	
	@Test
	def void testDiffOfModification() {
		// given
		
		// -- initial commit
		writeTrashFile('README.md', '# Readme')
		git.add.addFilepattern("README.md").call
		val oldCommit = git.commit.setMessage("Initial commit").call
		
		// -- modifying commit
		writeTrashFile('README.md', '''
			# Readme
			
			This is an additional line to be committed
			''')
		git.add.addFilepattern("README.md").call
		val newCommit = git.commit.setMessage("Additional line in readme").call
		
		// when
		val differences = gitService.calculateDiff(oldCommit.tree.getName(), newCommit.tree.getName())
		
		// then
		assertThat(differences).hasSize(1)
		differences.get(0) => [
			assertThat(changeType).isEqualTo(ChangeType.MODIFY)
			assertThat(oldPath).isEqualTo("README.md")
			assertThat(newPath).isEqualTo("README.md")
		]

	}

}