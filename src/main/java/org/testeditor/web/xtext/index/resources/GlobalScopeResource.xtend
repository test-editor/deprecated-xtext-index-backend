package org.testeditor.web.xtext.index.resources

import com.google.inject.Inject
import java.util.List
import javax.ws.rs.Path
import javax.ws.rs.Produces
import javax.ws.rs.QueryParam
import javax.ws.rs.core.MediaType
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.impl.ResourceSetBasedResourceDescriptions
import org.eclipse.xtext.scoping.IGlobalScopeProvider
import org.eclipse.xtext.util.StringInputStream
import javax.ws.rs.POST
import javax.ws.rs.Consumes

@Path("/xtext/index/global-scope")
@Produces(MediaType.APPLICATION_JSON)
class GlobalScopeResource implements IGlobalScopeResource {

	val IGlobalScopeProvider globalScopeProvider
	val ResourceSetBasedResourceDescriptions index


	new(IGlobalScopeProvider globalScopeProvider, ResourceSetBasedResourceDescriptions index) {
		this.globalScopeProvider = globalScopeProvider
		this.index = index
	}

	@POST
	@Consumes("text/plain")
	@Produces("application/json")
	override List<IEObjectDescription> getScope(String context, @QueryParam("reference") String eReferenceURIString) {
		val resource = createContextResource(context)
		val eReference = createEReference(eReferenceURIString)

		return globalScopeProvider.getScope(resource, eReference, null).allElements.toList
	}

	private def createContextResource(String context) {
		val resource = index.resourceSet.createResource(URI.createURI("dummy.tsl"))
		resource.load(new StringInputStream(context), emptyMap)
		return resource
	}

	private def createEReference(String eReferenceURIString) {
		val eReferenceURI = URI.createURI(eReferenceURIString)
		val ePackage = EPackage.Registry.INSTANCE.getEPackage(eReferenceURI.trimFragment().toString())
		return ePackage.eResource.getEObject(eReferenceURI.fragment) as EReference
	}

}
