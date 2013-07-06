package engine.gibbs.components;
import engine.gibbs.Component;

interface TickCmp extends Component
{
	function update( deltaSeconds : Float ) : Void;
}