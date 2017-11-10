package org.testeditor.web.xtext.index.resources

import com.fasterxml.jackson.core.type.TypeReference
import java.io.InputStream
import java.util.List
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.XtextPackage
import org.eclipse.xtext.resource.IEObjectDescription
import org.junit.Test
import org.testeditor.tcl.TclPackage
import org.testeditor.web.xtext.index.resources.bitbucket.AbstractIntegrationTest

import static javax.ws.rs.core.Response.Status.*
import static org.assertj.core.api.Assertions.assertThat

class GlobalScopeResourceIntegrationTest extends AbstractIntegrationTest {

	val LARGE_INDEX_SIZE = 100
	val MACRO_COLLECTION_REF_CONTEXT = '''
			package pack
			
			# Context
			
			* Some Teststep
			Macro: 
		'''
	val DEFAULT_FILE_URI_IN_INDEX = "pack/MacroLib.tml"
	val DEFAULT_FILE_IN_INDEX = '''
				package pack
				
				# MacroLib
				
				## FirstMacro
				
					template = "code"
				
					Component: SomeComponent
					- Some fixture call
			'''

	@Test
	def void macroReferencedByTcl() {
		// given
		addFileToIndex(DEFAULT_FILE_URI_IN_INDEX, DEFAULT_FILE_IN_INDEX)

		val context = MACRO_COLLECTION_REF_CONTEXT

		val macroCollectionReference = EcoreUtil.getURI(TclPackage.eINSTANCE.macroTestStepContext_MacroCollection).
			toString
		
		// when
		val response = postGlobalScopeRequest(context, macroCollectionReference,'tcl', 'pack/context.tcl')

		val payload = objectMapper.<List<IEObjectDescription>>readValue(response.entity as InputStream,
			new TypeReference<List<IEObjectDescription>>() {
			})

		// then
		assertThat(response.status).isEqualTo(OK.statusCode)
		assertThat(payload).satisfies [
			assertThat(it).isInstanceOf(List)
			assertThat(size).isEqualTo(1)
			assertThat(head.getEClass.name).isEqualTo("MacroCollection")
			assertThat(head.qualifiedName.toString).isEqualTo("MacroLib")
		]

	}
	
	/**
	 * The index does not actually require the context resource's content!
	 */
	@Test
	def void macroReferencedByTclWithoutContextContent() {
		// given
		addFileToIndex(DEFAULT_FILE_URI_IN_INDEX, DEFAULT_FILE_IN_INDEX)

		val context = null

		val macroCollectionReference = EcoreUtil.getURI(TclPackage.eINSTANCE.macroTestStepContext_MacroCollection).
			toString
		
		// when
		val response = postGlobalScopeRequest(context, macroCollectionReference,'tcl', 'pack/context.tcl')

		val payload = objectMapper.<List<IEObjectDescription>>readValue(response.entity as InputStream,
			new TypeReference<List<IEObjectDescription>>() {
			})

		// then
		assertThat(response.status).isEqualTo(OK.statusCode)
		assertThat(payload).satisfies [
			assertThat(it).isInstanceOf(List)
			assertThat(size).isEqualTo(1)
			assertThat(head.getEClass.name).isEqualTo("MacroCollection")
			assertThat(head.qualifiedName.toString).isEqualTo("MacroLib")
		]

	}

	@Test
	def void macroReferencedByTclOnLargeIndex() {
		// given
		indexOfSize(LARGE_INDEX_SIZE)

		val context = MACRO_COLLECTION_REF_CONTEXT

		val macroCollectionReference = EcoreUtil.getURI(TclPackage.eINSTANCE.macroTestStepContext_MacroCollection).
			toString

		// when
		val response = postGlobalScopeRequest(context, macroCollectionReference,'tcl', 'pack/context.tcl')

		val payload = objectMapper.<List<IEObjectDescription>>readValue(response.entity as InputStream,
			new TypeReference<List<IEObjectDescription>>() {
			})

		// then
		assertThat(response.status).isEqualTo(OK.statusCode)
		assertThat(payload).satisfies [
			assertThat(it).isInstanceOf(List)
			assertThat(size).isEqualTo(LARGE_INDEX_SIZE)
			assertThat(head.getEClass.name).isEqualTo("MacroCollection")
			assertThat(head.qualifiedName.toString).isEqualTo("MacroLib0")
			assertThat(last.qualifiedName.toString).isEqualTo("MacroLib" + (LARGE_INDEX_SIZE - 1))
		]

	}

	@Test
	def void noResourceNoContentCompletion() {
		// given
		val reference = EcoreUtil.getURI(XtextPackage.eINSTANCE.grammar_UsedGrammars).toString
		val contentType = "tsl"
		val contextURI = "example.tsl"
		val context = MACRO_COLLECTION_REF_CONTEXT

		// when
		val response = postGlobalScopeRequest(context, reference,contentType, contextURI)

		// then
		assertThat(response.status).isEqualTo(OK.statusCode)
	}

	@Test
	def void noContentTypeFallsBackToFileExtension() {
		// given
		val reference = EcoreUtil.getURI(XtextPackage.eINSTANCE.grammar_UsedGrammars).toString
		val contentType = null
		val contextURI = "example.tsl"
		val context = MACRO_COLLECTION_REF_CONTEXT

		// when
		val response = postGlobalScopeRequest(context, reference,contentType, contextURI)

		// then
		assertThat(response.status).isEqualTo(OK.statusCode)
	}

	@Test
	def void nullContextURICausesError() {
		// given
		val reference = EcoreUtil.getURI(XtextPackage.eINSTANCE.grammar_UsedGrammars).toString
		val contentType = null
		val contextURI = null
		val context = MACRO_COLLECTION_REF_CONTEXT

		// when
		val response = postGlobalScopeRequest(context, reference,contentType, contextURI)

		// then
		assertThat(response.status).isEqualTo(INTERNAL_SERVER_ERROR.statusCode)
		assertThat((response.entity as InputStream).deserializeException.message).isEqualTo(
			"No context URI was provided (URI is null).")
	}
	
	@Test
	def void emptyContextURICausesError() {
		// given
		val reference = EcoreUtil.getURI(XtextPackage.eINSTANCE.grammar_UsedGrammars).toString
		val contentType = "tsl"
		val contextURI = ""
		val context = MACRO_COLLECTION_REF_CONTEXT

		// when
		val response = postGlobalScopeRequest(context, reference,contentType, contextURI)

		// then
		assertThat(response.status).isEqualTo(INTERNAL_SERVER_ERROR.statusCode)
		assertThat((response.entity as InputStream).deserializeException.message).isEqualTo(
			"Failed to create resource for URI '' of type 'tsl'.")
	}

}
