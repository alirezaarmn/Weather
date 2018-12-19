#include "qcustomplot/CustomPlotItem.h"

#include "qcustomplot.h"
#include <QDebug>

CustomPlotItem::CustomPlotItem( QQuickItem* parent ) : QQuickPaintedItem( parent )
    , m_CustomPlot( new QCustomPlot() )
{
    setFlag( QQuickItem::ItemHasContents, true );
    // setRenderTarget(QQuickPaintedItem::FramebufferObject);
    // setAcceptHoverEvents(true);
    setAcceptedMouseButtons( Qt::AllButtons );

    connect( this, &QQuickPaintedItem::widthChanged, this, &CustomPlotItem::updateCustomPlotSize );
    connect( this, &QQuickPaintedItem::heightChanged, this, &CustomPlotItem::updateCustomPlotSize );
    connect(this, &CustomPlotItem::colorBackgroundChanged, this, &CustomPlotItem::setBackground);
}

CustomPlotItem::~CustomPlotItem()
{
    delete m_CustomPlot;
    m_CustomPlot = nullptr;
}

void CustomPlotItem::initCustomPlot()
{
    connect( m_CustomPlot, &QCustomPlot::afterReplot, this, &CustomPlotItem::onCustomReplot );

    m_CustomPlot->addGraph(); //min-Temp graph
    m_minGraphIndex = m_CustomPlot->graphCount() - 1;
    m_CustomPlot->addGraph(); //max-Temp graph
    m_maxGraphIndex = m_CustomPlot->graphCount() - 1;

    m_CustomPlot->addGraph(); // blue line
    m_CustomPlot->graph(m_minGraphIndex)->setPen(QPen(QColor(40, 110, 255)));
    m_CustomPlot->addGraph(); // red line
    m_CustomPlot->graph(m_maxGraphIndex)->setPen(QPen(QColor(255, 110, 40)));

    QSharedPointer<QCPAxisTickerTime> timeTicker(new QCPAxisTickerTime);
    timeTicker->setTimeFormat("%h:%m:%s");
    m_CustomPlot->xAxis->setTicker(timeTicker);
    m_CustomPlot->axisRect()->setupFullAxesBox();
    m_CustomPlot->yAxis->setRange(-1.2, 1.2);

    m_CustomPlot->replot();
}

void CustomPlotItem::setPlotData(QVector<double> xAxis, QVector<double> yAxis)
{
    m_CustomPlot->graph(m_minGraphIndex)->addData(xAxis, yAxis);
}

void CustomPlotItem::setBackground(QColor color)
{
    m_CustomPlot->setBackground(QBrush(color));
    m_CustomPlot->axisRect()->setBackground(QBrush(color));
}

void CustomPlotItem::paint( QPainter* painter )
{
    if (m_CustomPlot)
    {
        QPixmap    picture( boundingRect().size().toSize() );
        QCPPainter qcpPainter( &picture );

        //m_CustomPlot->replot();
        m_CustomPlot->toPainter( &qcpPainter );

        painter->drawPixmap( QPoint(), picture );
    }
}

QColor CustomPlotItem::getColorBackground()
{
    return _colorBackground;
}

void CustomPlotItem::setColorBackground(QColor color)
{
    if (color != _colorBackground)
    {
        _colorBackground = color;
        emit colorBackgroundChanged(color);
    }
}

void CustomPlotItem::mousePressEvent( QMouseEvent* event )
{
    qDebug() << Q_FUNC_INFO;
    routeMouseEvents( event );
}

void CustomPlotItem::mouseReleaseEvent( QMouseEvent* event )
{
    qDebug() << Q_FUNC_INFO;
    routeMouseEvents( event );
}

void CustomPlotItem::mouseMoveEvent( QMouseEvent* event )
{
    routeMouseEvents( event );
}

void CustomPlotItem::mouseDoubleClickEvent( QMouseEvent* event )
{
    qDebug() << Q_FUNC_INFO;
    routeMouseEvents( event );
}

void CustomPlotItem::graphClicked( QCPAbstractPlottable* plottable )
{
    qDebug() << Q_FUNC_INFO << QString( "Clicked on graph '%1 " ).arg( plottable->name() );
}

void CustomPlotItem::routeMouseEvents( QMouseEvent* event )
{
    if (m_CustomPlot)
    {
        QMouseEvent* newEvent = new QMouseEvent( event->type(), event->localPos(), event->button(), event->buttons(), event->modifiers() );
        //QCoreApplication::sendEvent( m_CustomPlot, newEvent );
        QCoreApplication::postEvent( m_CustomPlot, newEvent );
    }
}

void CustomPlotItem::updateCustomPlotSize()
{
    if (m_CustomPlot)
    {
        m_CustomPlot->setGeometry( 0, 0, width(), height() );
    }
}

void CustomPlotItem::onCustomReplot()
{
    qDebug() << Q_FUNC_INFO;
    update();
}
